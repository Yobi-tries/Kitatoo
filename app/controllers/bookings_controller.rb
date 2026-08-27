class BookingsController < ApplicationController
  def create
    @artist_profile = ArtistProfile.find(params[:artist_profile_id])

    if booking_params[:starts_at].blank? || booking_params[:ends_at].blank?
      return redirect_to artist_profile_public_availabilities_path(@artist_profile), alert: "Please select a time slot."
    end

    address = @artist_profile.addresses.find(booking_params[:address_id])
    availability = @artist_profile.availabilities.find_or_create_by!(
      starts_at: booking_params[:starts_at], ends_at: booking_params[:ends_at]
    ) { |a| a.address = address }

    @booking = availability.build_booking(client: current_user, description: booking_params[:description])

    if @booking.save
      conversation = Conversation.find_or_create_by!(client: current_user, artist_profile: @artist_profile)
      redirect_to conversation_path(conversation), notice: "Booking request sent!"
    else
      redirect_to artist_profile_public_availabilities_path(@artist_profile),
                  alert: @booking.errors.full_messages.to_sentence
    end
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

  private

  def booking_params
    params.require(:booking).permit(:address_id, :starts_at, :ends_at, :description)
  end
end
