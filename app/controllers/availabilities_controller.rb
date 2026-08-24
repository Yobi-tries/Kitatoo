class AvailabilitiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  # GET /artist_profile/availabilities (gestion perso)
  # GET /artist_profiles/:artist_profile_id/availabilities (consultation publique)
  def index
  end

  def create
  end

  def update
  end

  def destroy
  end
end
