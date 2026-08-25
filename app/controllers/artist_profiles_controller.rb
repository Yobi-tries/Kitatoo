class ArtistProfilesController < ApplicationController
  def new
  end

  def create
  end

  def edit
    @artist_profile = current_user.artist_profile
    redirect_to new_artist_profile_path, alert: "You don't have an artist profile yet." unless @artist_profile
  end

  def update
    @artist_profile = current_user.artist_profile

    if @artist_profile.update(artist_profile_update_params)
      redirect_to edit_artist_profile_path, notice: "Your profile has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def artist_profile_update_params
    params.require(:artist_profile).permit(
      :display_name, :bio, :styles, :professional_status,
      :pricing_grid, :social_links, :published
    )
  end
end
