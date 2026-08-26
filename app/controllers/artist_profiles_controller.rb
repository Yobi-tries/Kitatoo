class ArtistProfilesController < ApplicationController
  before_action :redirect_if_artist_profile_exists, only: [ :new, :create ]

  def new
    @artist_profile = current_user.build_artist_profile
  end

  def create
    @artist_profile = current_user.build_artist_profile(artist_profile_params)
    @artist_profile.published = true

    if @artist_profile.save
      redirect_to edit_artist_profile_path, notice: "Your artist profile has been created! Complete it to be visible in search."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @artist_profile = current_user.artist_profile
    redirect_to new_artist_profile_path, alert: "You don't have an artist profile yet." unless @artist_profile
  end

  def update
    @artist_profile = current_user.artist_profile

    if @artist_profile.update(artist_profile_update_params)
      @artist_profile.tags = tag_names_param.map { |name| Tag.find_or_create_by_name!(name) }.uniq
      redirect_to edit_artist_profile_path, notice: "Your profile has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def artist_profile_update_params
    permitted = params.require(:artist_profile).permit(
      :display_name, :bio, :professional_status,
      :social_links, :published,
      pricing_grid: [ :prestation, :prix ]
    )

    if permitted[:pricing_grid]
      permitted[:pricing_grid] = permitted[:pricing_grid].values.reject { |item| item["prestation"].blank? }
    end

    permitted
  end

  def tag_names_param
    Array(params.dig(:artist_profile, :tag_names)).map(&:strip).reject(&:blank?).uniq { |name| name.downcase }
  end

  private

  def redirect_if_artist_profile_exists
    redirect_to edit_artist_profile_path, alert: "You already have an artist profile." if current_user.artist_profile.present?
  end

  def artist_profile_params
    params.require(:artist_profile).permit(:display_name)
  end
end
