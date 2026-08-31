class LikesController < ApplicationController
  def create
    @artist_profile = ArtistProfile.find(params[:artist_profile_id])
    current_user.likes.find_or_create_by(artist_profile: @artist_profile)
    redirect_back fallback_location: artist_path(@artist_profile)
  end

  def destroy
    @like = current_user.likes.find_by(artist_profile_id: params[:artist_profile_id])
    @like&.destroy
    redirect_back fallback_location: artist_path(params[:artist_profile_id])
  end
end
