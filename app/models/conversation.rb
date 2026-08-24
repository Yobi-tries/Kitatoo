class Conversation < ApplicationRecord
  belongs_to :client, class_name: "User"
  belongs_to :artist_profile
  has_many :messages, dependent: :destroy
end
