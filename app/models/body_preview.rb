class BodyPreview < ApplicationRecord
  belongs_to :user
  belongs_to :tattoo_generation, optional: true

  validates :placement, presence: true
  validates :source_image_url, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  PLACEMENTS = ["Forearm", "Upper arm", "Shoulder", "Chest", "Back", "Thigh", "Calf", "Ankle", "Other"].freeze

  PLACEMENT_HINTS = {
    "Forearm" => "wrap naturally around the forearm with realistic curvature and perspective",
    "Upper arm" => "wrap naturally around the curve of the upper arm",
    "Shoulder" => "follow the rounded surface of the shoulder",
    "Chest" => "sit naturally across the chest",
    "Back" => "sit naturally across the back",
    "Thigh" => "wrap naturally around the thigh",
    "Calf" => "wrap naturally around the calf",
    "Ankle" => "sit naturally on the ankle"
  }.freeze

  def self.build_prompt(placement:)
    <<~PROMPT
      You are creating a realistic body-placement preview, not a new tattoo design.

      Take the exact tattoo design shown in the supplied reference image and preserve it as faithfully as possible: same composition, shapes, proportions, linework, shading, details, and overall visual identity. Do not add or remove any tattoo elements, and do not reinterpret or change the tattoo style.

      Show this exact tattoo realistically applied to a human #{placement.downcase}, as if actually tattooed on real skin. #{PLACEMENT_HINTS[placement] || "adapt only what is necessary for realistic perspective and natural placement on this body area"}.

      The result should look like a real photo: realistic skin texture, natural lighting, the tattoo clearly and fully visible.
    PROMPT
  end
end
