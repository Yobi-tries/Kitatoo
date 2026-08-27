class PortfolioItemsController < ApplicationController
  def create
    artist_profile = current_user.artist_profile

    unless artist_profile
      redirect_to new_artist_profile_path, alert: "Create your artist profile first."
      return
    end

    images = Array(params[:images])

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
end
