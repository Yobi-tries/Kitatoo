class UsersController < ApplicationController
  def show
    @user = current_user
    @liked_artist_profiles = @user.liked_artist_profiles.includes(:portfolio_items)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    upload_avatar if params.dig(:user, :avatar).present?

    if @user.update(user_params)
      redirect_to user_path, notice: "Your profile has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :city, :bio)
  end

  def upload_avatar
    upload = Cloudinary::Uploader.upload(params[:user][:avatar].tempfile.path)
    @user.avatar_url = upload["secure_url"]
    @user.avatar_public_id = upload["public_id"]
  end
end
