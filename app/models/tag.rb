class Tag < ApplicationRecord
  has_many :artist_profile_tags, dependent: :destroy
  has_many :artist_profiles, through: :artist_profile_tags

  validates :name, presence: true
  validates :normalized_name, presence: true, uniqueness: true

  before_validation :set_normalized_name

  def self.normalize(raw_name)
    raw_name.to_s.strip.downcase
  end

  def self.find_or_create_by_name!(raw_name)
    normalized = normalize(raw_name)
    find_by(normalized_name: normalized) || create!(name: raw_name.to_s.strip, normalized_name: normalized)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    find_by!(normalized_name: normalized)
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize(name)
  end
end
