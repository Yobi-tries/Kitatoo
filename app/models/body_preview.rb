class BodyPreview < ApplicationRecord
  belongs_to :user
  belongs_to :tattoo_generation, optional: true

  validates :placement, presence: true
  validates :source_image_url, presence: true
  validates :body_image_url, presence: true

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
      You are creating a realistic body-placement preview from two reference images, not a new tattoo design.

      Image 1 is the user's body photo. Preserve the person, pose, framing, anatomy, skin tone and texture, lighting and background exactly as shown.

      Image 2 is the exact tattoo design. Preserve it as faithfully as possible: same composition, shapes, proportions, linework, shading, details, and overall visual identity. Do not add or remove any tattoo elements, and do not reinterpret or change the tattoo style.

      Apply the tattoo from Image 2 realistically onto Image 1's #{placement.downcase}, as if actually tattooed on that real skin. #{PLACEMENT_HINTS[placement] || 'adapt only what is necessary for realistic perspective and natural placement on this body area'}.

      The result must look like a real, unedited photo of the same person from Image 1: realistic skin texture, natural lighting and shadow, the tattoo clearly and fully visible and wrapped naturally to body contours.
    PROMPT
  end
end
