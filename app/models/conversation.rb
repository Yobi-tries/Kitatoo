class Conversation < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :artist_profile

  validates :client_id, uniqueness: { scope: :artist_profile_id }

  has_many :messages, dependent: :destroy

  def participant?(user)
    client_id == user.id || artist_profile.user_id == user.id
  end

  def other_participant_name(user)
    user.id == client.id ? artist_profile.display_name : client.username
  end

  def mark_read!(user)
    if user.id == client_id
      update_column(:client_last_read_at, Time.current)
    else
      update_column(:artist_last_read_at, Time.current)
    end
  end

  def unread_for?(user)
    last_msg = messages.order(created_at: :desc).pick(:created_at, :user_id)
    return false unless last_msg

    msg_at, sender_id = last_msg
    return false if sender_id == user.id

    read_at = user.id == client_id ? client_last_read_at : artist_last_read_at
    read_at.nil? || msg_at > read_at
  end
end
