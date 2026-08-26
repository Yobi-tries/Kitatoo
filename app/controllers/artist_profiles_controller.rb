class ArtistProfilesController < ApplicationController
  before_action :redirect_if_already_artist, only: [:new, :create]

  def new
    @artist_profile = current_user.build_artist_profile
  end

  def create
    @artist_profile = current_user.build_artist_profile(artist_profile_params)

    if @artist_profile.save
      redirect_to edit_artist_profile_path, notice: "Ton profil artiste est créé. Complète-le maintenant."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  private

  def artist_profile_params
    params.require(:artist_profile).permit(:display_name)
  end

  def redirect_if_already_artist
    return unless current_user.artist_profile

    redirect_to edit_artist_profile_path, notice: "Tu as déjà un profil artiste."
  end
end
