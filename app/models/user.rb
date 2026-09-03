class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :birthdate, presence: true

  has_one :artist_profile, dependent: :destroy
  has_many :bookings, foreign_key: :client_id, inverse_of: :client, dependent: :destroy
  has_many :conversations, foreign_key: :client_id, inverse_of: :client, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :tattoo_generations, dependent: :destroy
  has_many :body_previews, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_artist_profiles, through: :likes, source: :artist_profile

  def unread_conversations?
    all_conversations.any? { |c| c.unread_for?(self) }
  end

  def unnotified_bookings?
    relevant_bookings.any? { |b| b.unnotified_for?(self) }
  end

  def unnotified_tattoo_generator_results?
    tattoo_generations.unnotified.exists? || body_previews.unnotified.exists?
  end

  private

  def all_conversations
    if artist_profile
      Conversation.where(client_id: id).or(Conversation.where(artist_profile: artist_profile))
    else
      Conversation.where(client_id: id)
    end
  end

  def relevant_bookings
    scope = Booking.joins(:availability).where.not(status: [ :cancelled, :completed ])
    if artist_profile
      scope.where(client_id: id)
        .or(scope.where(availabilities: { artist_profile_id: artist_profile.id }))
    else
      scope.where(client_id: id)
    end
  end
end
