class ArtistsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
  end

  def show
    @artist_profile = ArtistProfile.find(params[:id])
  end
end
