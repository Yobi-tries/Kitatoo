class BookingsController < ApplicationController
  def index
    @artist_profile = current_user.artist_profile

    client_scope = current_user.bookings.joins(:availability)
                               .includes(availability: :artist_profile)

    @client_upcoming = client_scope.where.not(status: :cancelled)
                                   .where("availabilities.starts_at >= ?", Time.current)
                                   .order("availabilities.starts_at ASC")
    @client_past = client_scope.where.not(status: :cancelled)
                               .where("availabilities.starts_at < ?", Time.current)
                               .order("availabilities.starts_at DESC")
    @client_cancelled = client_scope.where(status: :cancelled)
                                    .order("availabilities.starts_at DESC")
    @client_conversations_by_artist = current_user.conversations.index_by(&:artist_profile_id)

    return unless @artist_profile

    @addresses = @artist_profile.addresses.order(:id)
    @selected_address = @addresses.find_by(id: params[:address_id]) if params[:address_id].present?
    @status = params[:status].presence_in(%w[requests upcoming history cancelled]) || "requests"

    artist_scope = Booking.joins(:availability)
                          .where(availabilities: { artist_profile_id: @artist_profile.id })
                          .includes(:client, availability: %i[artist_profile address])
    artist_scope = artist_scope.where(availabilities: { address_id: @selected_address.id }) if @selected_address

    @artist_pending = artist_scope.where(status: %i[selected artist_confirmed])
                                  .order("availabilities.starts_at ASC")
    @artist_upcoming = artist_scope.where(status: :confirmed)
                                   .where("availabilities.starts_at >= ?", Time.current)
                                   .order("availabilities.starts_at ASC")
    @artist_to_complete = artist_scope.where(status: :confirmed)
                                      .where("availabilities.starts_at < ?", Time.current)
                                      .order("availabilities.starts_at DESC")
    @artist_history = artist_scope.where(status: :completed)
                                  .order("availabilities.starts_at DESC")
    @artist_cancelled = artist_scope.where(status: :cancelled)
                                    .order("availabilities.starts_at DESC")
    @artist_conversations_by_client = @artist_profile.conversations.index_by(&:client_id)
  end

  def create
    @artist_profile = ArtistProfile.find(params[:artist_profile_id])

    if booking_params[:starts_at].blank? || booking_params[:ends_at].blank?
      return redirect_to artist_profile_public_availabilities_path(@artist_profile, address_id: booking_params[:address_id]),
                          alert: "Please select a time slot."
    end

    address = @artist_profile.addresses.find(booking_params[:address_id])
    availability = @artist_profile.availabilities.find_or_create_by!(
      starts_at: booking_params[:starts_at], ends_at: booking_params[:ends_at]
    ) { |a| a.address = address }

    if availability.booking.present?
      return shift_and_redirect(starts_at: availability.starts_at, ends_at: availability.ends_at,
                                address: address, description: booking_params[:description])
    end

    @booking = availability.build_booking(client: current_user, description: booking_params[:description])

    if @booking.save
      conversation = Conversation.find_or_create_by!(client: current_user, artist_profile: @artist_profile)
      conversation.messages.create!(
        user: current_user,
        body: "Booking request: #{availability.starts_at.strftime('%A %d %B, %H:%M')}–" \
              "#{availability.ends_at.strftime('%H:%M')} at #{address.label.presence || address.city}. " \
              "\"#{@booking.description}\""
      )
      redirect_to conversation_path(conversation), notice: "Booking request sent!"
    else
      redirect_to artist_profile_public_availabilities_path(@artist_profile, address_id: address.id),
                  alert: @booking.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordInvalid => e
    raise unless e.record.is_a?(Availability) &&
                 e.record.errors.of_kind?(:base, "overlaps with an existing availability for this artist")

    shift_and_redirect(starts_at: e.record.starts_at, ends_at: e.record.ends_at,
                       address: address, description: booking_params[:description])
  end

  def confirm
    @booking = Booking.find(params[:id])
    artist_profile = @booking.availability.artist_profile

    unless current_user.artist_profile == artist_profile
      return redirect_to root_path, alert: "Not authorized."
    end

    @booking.update!(duration: params.dig(:booking, :duration).to_i, status: :artist_confirmed)

    conversation = Conversation.find_by(client_id: @booking.client_id, artist_profile: artist_profile)
    redirect_to conversation_path(conversation), notice: "Duration set. Waiting for client confirmation."
  end

  def accept
    @booking = Booking.find(params[:id])

    unless current_user == @booking.client
      return redirect_to root_path, alert: "Not authorized."
    end

    ActiveRecord::Base.transaction do
      @booking.confirmed!
      @booking.availability.booked!
    end

    conversation = Conversation.find_by(client_id: @booking.client_id,
                                        artist_profile: @booking.availability.artist_profile)
    redirect_to conversation_path(conversation), notice: "Booking confirmed!"
  end

  def cancel
    @booking = Booking.find(params[:id])
    artist_profile = @booking.availability.artist_profile
    is_artist = current_user.artist_profile == artist_profile
    is_client = current_user == @booking.client
    authorized = @booking.confirmed? ? is_artist : (is_artist || is_client)

    return redirect_to root_path, alert: "Not authorized." unless authorized

    conversation = Conversation.find_by(client_id: @booking.client_id, artist_profile: artist_profile)
    conversation.messages.create!(
      user: current_user,
      body: "Booking cancelled: #{@booking.availability.starts_at.strftime('%A %d %B, %H:%M')} — " \
            "cancelled by #{is_artist ? 'the artist' : 'the client'}."
    )
    @booking.cancelled!

    redirect_to conversation_path(conversation), notice: "Booking cancelled."
  end

  def complete
    @booking = Booking.find(params[:id])
    artist_profile = @booking.availability.artist_profile

    unless current_user.artist_profile == artist_profile
      return redirect_to root_path, alert: "Not authorized."
    end

    conversation = Conversation.find_by(client_id: @booking.client_id, artist_profile: artist_profile)
    conversation.messages.create!(
      user: current_user,
      body: "Booking marked as completed: #{@booking.availability.starts_at.strftime('%A %d %B, %H:%M')}."
    )
    @booking.completed!

    redirect_to conversation_path(conversation), notice: "Booking marked as completed!"
  end

  private

  def shift_and_redirect(starts_at:, ends_at:, address:, description:)
    shifted = Availability.next_available_slot(artist_profile: @artist_profile, starts_at: starts_at, ends_at: ends_at,
                                               schedule: address.schedule)

    if shifted
      flash[:booking_draft] = {
        "starts_at" => shifted[:starts_at].iso8601,
        "ends_at" => shifted[:ends_at].iso8601,
        "address_id" => address.id,
        "description" => description
      }
      redirect_to artist_profile_public_availabilities_path(
        @artist_profile, month: shifted[:starts_at].strftime("%Y-%m"), address_id: address.id
      ), alert: "That time was just booked by someone else. We've proposed the next available slot below — " \
                "please review and confirm it."
    else
      redirect_to artist_profile_public_availabilities_path(@artist_profile, address_id: address.id),
                  alert: "That time was just booked by someone else, and no later slot is available that day. " \
                         "Please pick a different time."
    end
  end

  def booking_params
    params.require(:booking).permit(:address_id, :starts_at, :ends_at, :description)
  end
end
