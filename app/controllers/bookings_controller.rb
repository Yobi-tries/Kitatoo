class BookingsController < ApplicationController
  def create
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
end
