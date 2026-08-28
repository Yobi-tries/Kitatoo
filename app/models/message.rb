class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user

  validates :body, presence: true

  after_create_commit -> {
    broadcast_append_to conversation,
      target: "messages",
      partial: "conversations/message",
      locals: { message: self }
  }
end
