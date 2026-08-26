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
      @artists = @artists.where("artist_profiles.styles ILIKE ?", "%#{params[:style]}%")
    end

    if params[:location].present?
      @artists = @artists.where("addresses.city ILIKE ?", "%#{params[:location]}%")
    end

    @searching = params[:query].present? || params[:style].present? || params[:location].present?
    @artists = @searching ? @artists.order(:display_name) : @artists.to_a.sample(6)


    @styles = ArtistProfile.where(published: true).pluck(:styles).compact
                           .flat_map { |s| s.split(",") }.map(&:strip)
                           .tally.sort_by { |name, count| [ -count, name ] }.map(&:first)
    @cities = Address.joins(:artist_profile).where(artist_profiles: { published: true })
                     .distinct.order(:city).pluck(:city)
  end

  def show
    @artist_profile = ArtistProfile.find(params[:id])
    @tags = @artist_profile.styles.to_s.split(",").map { |tag| tag.strip }
    @prices = @artist_profile.pricing_grid || []
    amounts = @prices.map { |row| row["prix"] }
    @min_price = amounts.min
    @max_price = amounts.max
  end

end
