class TattooGeneration < ApplicationRecord
  belongs_to :user

  validates :prompt, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }
end
