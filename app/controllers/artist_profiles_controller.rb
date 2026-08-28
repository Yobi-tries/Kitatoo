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
    upload_avatar if params.dig(:artist_profile, :avatar).present?

    if @artist_profile.update(artist_profile_update_params)
      @artist_profile.tags = tag_names_param.map { |name| Tag.find_or_create_by_name!(name) }.uniq
      redirect_to artist_path(@artist_profile), notice: "Your profile has been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def artist_profile_update_params
    permitted = params.require(:artist_profile).permit(
      :display_name, :bio, :professional_status,
      :published,
      pricing_grid: [ :prestation, :prix ]
    )

    permitted[:schedule] = build_schedule if params[:artist_profile][:schedule].present?

    if permitted[:pricing_grid]
      permitted[:pricing_grid] = permitted[:pricing_grid].values.reject { |item| item["prestation"].blank? }
    end

    if params[:artist_profile][:social_links].present?
      sl = params[:artist_profile][:social_links]
      permitted[:social_links] = {
        "instagram" => sl[:instagram].presence,
        "pinterest" => sl[:pinterest].presence
      }
    end

    permitted
  end


  def tag_names_param
    Array(params.dig(:artist_profile, :tag_names)).map(&:strip).reject(&:blank?).uniq { |name| name.downcase }
  end

  def upload_avatar
    upload = Cloudinary::Uploader.upload(params[:artist_profile][:avatar].tempfile.path)
    @artist_profile.avatar_url = upload["secure_url"]
    @artist_profile.avatar_public_id = upload["public_id"]
  end

  def build_schedule
    s = params[:artist_profile][:schedule]
    days = {}
    %w[monday tuesday wednesday thursday friday saturday sunday].each do |day|
      if s.dig(:days, day, :enabled) == "1"
        days[day] = { "start" => s.dig(:days, day, :start), "end" => s.dig(:days, day, :end) }
      else
        days[day] = nil
      end
    end
    days_off = (s[:days_off] || {}).values.reject(&:blank?)
    {
      "slot_duration" => s[:slot_duration].to_i,
      "period_start" => s[:period_start],
      "period_end" => s[:period_end],
      "days" => days,
      "days_off" => days_off
    }
  end

  def redirect_if_artist_profile_exists
    redirect_to edit_artist_profile_path, alert: "You already have an artist profile." if current_user.artist_profile.present?
  end

  def artist_profile_params
    params.require(:artist_profile).permit(:display_name)
  end
end
