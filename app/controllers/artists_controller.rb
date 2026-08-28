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

    @distances = {}

    if params[:location].present?
      nearby = Address.near(params[:location], 20_000).to_a
      nearby.each { |address| @distances[address.artist_profile_id] ||= address.distance }
      ordered_ids = nearby.map(&:artist_profile_id).uniq
      @artists = @artists.where(id: ordered_ids).to_a.sort_by { |artist| ordered_ids.index(artist.id) }
    elsif @searching
      @artists = @artists.order(:display_name)
    else
      @default_city = current_user&.city.presence || "Paris"
      nearby = Address.near(@default_city, 20_000).to_a
      nearby.each { |address| @distances[address.artist_profile_id] ||= address.distance }
      ordered_ids = nearby.map(&:artist_profile_id).uniq
      @artists = @artists.where(id: ordered_ids).to_a.sort_by { |a| ordered_ids.index(a.id) }
    end

    @style_counts = Tag.joins(:artist_profiles).where(artist_profiles: { published: true })
                       .pluck(:name)
                       .tally.sort_by { |name, count| [ -count, name ] }
    @styles = @style_counts.map(&:first)
    @cities = Address.joins(:artist_profile).where(artist_profiles: { published: true })
                     .distinct.order(:city).pluck(:city)
  end

  def show
    @artist_profile = ArtistProfile.find(params[:id])
    @tags = @artist_profile.tags.order(:name)
    @prices = @artist_profile.pricing_grid || []
    amounts = @prices.map { |row| row["prix"].to_f }.reject(&:zero?)
    @min_price = amounts.min&.to_i
    @max_price = amounts.max&.to_i
    @markers = @artist_profile.addresses.geocoded.map do |address|
      { lat: address.latitude, lng: address.longitude }
    end
  end
end
