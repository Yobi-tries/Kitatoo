class AddressesController < ApplicationController
  before_action :set_artist_profile
  before_action :set_address, only: [ :update, :destroy ]

  def index
    @addresses = @artist_profile.addresses.order(:id)
    @new_address = @artist_profile.addresses.build
  end

  def create
    @new_address = @artist_profile.addresses.build(address_params)

    if @new_address.save
      redirect_to artist_profile_addresses_path, notice: "Address added."
    else
      @addresses = @artist_profile.addresses.order(:id)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      redirect_to artist_profile_addresses_path, notice: "Address updated."
    else
      @addresses = @artist_profile.addresses.map { |a| a.id == @address.id ? @address : a }
      @new_address = @artist_profile.addresses.build
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to artist_profile_addresses_path, notice: "Address removed."
  end

  private

  def set_artist_profile
    @artist_profile = current_user.artist_profile
    redirect_to new_artist_profile_path, alert: "You don't have an artist profile yet." unless @artist_profile
  end

  def set_address
    @address = @artist_profile.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:label, :street, :zipcode, :city)
  end
end
