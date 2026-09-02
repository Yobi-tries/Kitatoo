class BodyPreview < ApplicationRecord
  belongs_to :user
  belongs_to :tattoo_generation, optional: true

  validates :source_image_url, presence: true
  validates :body_image_url, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  def self.build_prompt
    <<~PROMPT
      You are creating a realistic body-placement preview from two reference images, not a new tattoo design.

      Image 1 is the user's body photo and shows the intended placement area. Preserve the person, anatomy, pose, framing, skin, lighting and background. Apply the exact tattoo design from Image 2 naturally onto the clearly visible, central body area shown in Image 1. Match the skin's perspective and curvature. Do not move or redesign the tattoo and do not invent another body area.

      Image 2 is the exact tattoo design. Preserve it as faithfully as possible: same composition, shapes, proportions, linework, shading, details, and overall visual identity. Do not add, remove or reinterpret any tattoo elements.

      The result must look like a real, unedited photo of the same person from Image 1: realistic skin texture, natural lighting and shadow, the tattoo clearly and fully visible.
    PROMPT
  end
end
