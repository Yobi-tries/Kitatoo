class Conversation < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :artist_profile

  validates :client_id, uniqueness: { scope: :artist_profile_id }

  has_many :messages, dependent: :destroy

  def participant?(user)
    client_id == user.id || artist_profile.user_id == user.id
  end
end
