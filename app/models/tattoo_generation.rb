class TattooGeneration < ApplicationRecord
  belongs_to :user

  validates :prompt, presence: true
end
