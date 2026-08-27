class ArtistsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @artists = ArtistProfile.where(published: true).left_joins(:addresses).distinct

    if params[:query].present?
      @artists = @artists.where(
        "artist_profiles.display_name ILIKE :q
         OR artist_profiles.bio ILIKE :q
         OR artist_profiles.styles ILIKE :q
         OR addresses.city ILIKE :q",
        q: "%#{params[:query]}%"
      )
    end

    if params[:style].present?
      @artists = @artists.joins(:tags).where(tags: { normalized_name: Tag.normalize(params[:style]) })
    end

    @searching = params[:query].present? || params[:style].present? || params[:location].present?

    if params[:location].present?
      ordered_ids = Address.near(params[:location], 100).map(&:artist_profile_id).uniq
      @artists = @artists.where(id: ordered_ids).to_a.sort_by { |artist| ordered_ids.index(artist.id) }
    elsif @searching
      @artists = @artists.order(:display_name)
    else
      @artists = @artists.to_a.sample(6)
    end

    @styles = Tag.joins(:artist_profiles).where(artist_profiles: { published: true })
                 .pluck(:name)
                 .tally.sort_by { |name, count| [ -count, name ] }.map { |name, count| name }
    @cities = Address.joins(:artist_profile).where(artist_profiles: { published: true })
                     .distinct.order(:city).pluck(:city)
  end

  def show
    @artist_profile = ArtistProfile.find(params[:id])
    @month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.today
    @tags = @artist_profile.tags.order(:name)
    @prices = @artist_profile.pricing_grid || []
    amounts = @prices.map { |row| row["prix"] }
    @min_price = amounts.min
    @max_price = amounts.max
    @markers = @artist_profile.addresses.geocoded.map do |address|
      { lat: address.latitude, lng: address.longitude }
    end
  end
end
