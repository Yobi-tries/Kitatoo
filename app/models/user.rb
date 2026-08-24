class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :artist_profile, dependent: :destroy
  has_many :bookings, foreign_key: :client_id, inverse_of: :client, dependent: :destroy
  has_many :conversations, foreign_key: :client_id, inverse_of: :client, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :tattoo_generations, dependent: :destroy
end
