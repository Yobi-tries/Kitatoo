class ArtistProfilesController < ApplicationController
  before_action :redirect_if_artist_profile_exists, only: [ :new, :create ]

  def new
    @artist_profile = current_user.build_artist_profile
  end

  def create
    @artist_profile = current_user.build_artist_profile(artist_profile_params)

    if @artist_profile.save
      redirect_to edit_artist_profile_path, notice: "Your artist profile has been created! Complete it to be visible in search."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  private

  def redirect_if_artist_profile_exists
    redirect_to edit_artist_profile_path, alert: "You already have an artist profile." if current_user.artist_profile.present?
  end

  def artist_profile_params
    params.require(:artist_profile).permit(:display_name)
  end
end
