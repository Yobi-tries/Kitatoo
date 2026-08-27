class AvailabilitiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  # GET /artist_profile/availabilities (gestion perso)
  # GET /artist_profiles/:artist_profile_id/availabilities (consultation publique)
  def index
    @artist_profile = ArtistProfile.find(params[:artist_profile_id])
    @addresses = @artist_profile.addresses.order(:id)
    @month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.today

    draft = flash[:booking_draft] || {}
    @booking = Booking.new(description: draft["description"])
    @prefill_address_id = draft["address_id"]
    @prefill_starts_at = draft["starts_at"]
    @prefill_ends_at = draft["ends_at"]
  end

  def create
  end

  def update
  end

  def destroy
  end
end
