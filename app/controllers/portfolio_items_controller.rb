class PortfolioItemsController < ApplicationController
  before_action :set_portfolio_item, only: [ :update, :destroy ]

  def create
    artist_profile = current_user.artist_profile

    unless artist_profile
      redirect_to new_artist_profile_path, alert: "Create your artist profile first."
      return
    end

    images = Array(params[:images]).reject(&:blank?)

    if images.empty?
      redirect_back fallback_location: edit_artist_profile_path,
                    alert: "Please select at least one image."
      return
    end

    images.each do |image|
      upload = Cloudinary::Uploader.upload(image.tempfile.path)

      artist_profile.portfolio_items.create!(
        image_url: upload["secure_url"]
      )
    end

    redirect_back fallback_location: edit_artist_profile_path,
                  notice: "#{images.size} photo(s) added to your portfolio."
  end

  def update
    position = params[:role] == "avatar" ? 2 : 1
    @portfolio_item.artist_profile.portfolio_items.where(position: position).update_all(position: nil)
    @portfolio_item.update(position: position)
    redirect_back fallback_location: artist_path(@portfolio_item.artist_profile),
                  notice: "Image updated."
  end

  def destroy
    artist_profile = @portfolio_item.artist_profile
    @portfolio_item.destroy
    redirect_back fallback_location: artist_path(artist_profile),
                  notice: "Photo removed."
  end

  def bulk_destroy
    removed = current_user.artist_profile.portfolio_items.where(id: params[:ids]).destroy_all
    redirect_back fallback_location: artist_path(current_user.artist_profile),
                  notice: "#{removed.size} photo(s) removed."
  end

  private

  def set_portfolio_item
    @portfolio_item = current_user.artist_profile.portfolio_items.find(params[:id])
  end
end
