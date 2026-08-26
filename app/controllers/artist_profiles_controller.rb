class ArtistProfilesController < ApplicationController
  def new
  end

  def create
  end

  def edit
    @artist_profile = current_user.artist_profile
  end

  def update
    @artist_profile = current_user.artist_profile
    if @artist_profile.update(artist_profile_params)
      redirect_to artist_path(@artist_profile), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def artist_profile_params
    items = params[:artist_profile][:pricing_grid] || {}
    cleaned = items.values.reject { |item| item["prestation"].blank? }
    { pricing_grid: cleaned }
  end
end
