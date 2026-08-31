class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user

  validate :body_or_photo_present

  private

  def body_or_photo_present
    errors.add(:base, "Message must have text or a photo") unless body.present? || photo_url.present?
  end

  after_create_commit -> {
    broadcast_append_to conversation,
      target: "messages",
      partial: "conversations/message",
      locals: { message: self }
  }
end
