class TattooGeneration < ApplicationRecord
  belongs_to :user

  validates :prompt, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  PLACEMENTS = ["Forearm", "Upper arm", "Shoulder", "Chest", "Back", "Thigh", "Calf", "Ankle", "Other"].freeze

  PLACEMENT_COMPOSITION_HINTS = {
    "Forearm" => "favor an elongated, readable composition that flows naturally along the forearm",
    "Upper arm" => "favor a composition that wraps naturally around the curve of the upper arm",
    "Shoulder" => "account for the rounded, curved surface of the shoulder in the composition",
    "Chest" => "allow a wider, more expansive composition suited to the chest",
    "Back" => "allow a wider, more expansive composition across the larger canvas of the back",
    "Thigh" => "favor a vertically elongated composition suited to the thigh",
    "Calf" => "favor a composition that follows the elongated, curved shape of the calf",
    "Ankle" => "favor a compact, smaller-scale composition suited to the ankle"
  }.freeze

  # Guided-mode prompt builder: deterministic string template, no extra LLM call.
  # style_names keeps whatever order the caller selected them in -- this method never
  # decides which one is "primary"; that decision is explicitly delegated to the image
  # model itself via the wording of style_instruction below.
  def self.build_guided_prompt(idea:, style_names:, placement:, has_references:)
    lines = []
    lines << "You are creating an original tattoo design concept, not a photo or a finished tattoo on skin."
    lines << "Subject: #{idea}"
    lines << "Style: #{style_instruction(style_names)}"
    lines << "Placement: this design is for the #{placement}; " \
             "#{PLACEMENT_COMPOSITION_HINTS[placement] || "favor a composition that fits naturally on this body area"}."

    if has_references
      lines << "References: use the attached reference image(s) as secondary visual inspiration for " \
               "composition, linework, shapes or visual language -- they support but do not replace the " \
               "subject above, and should not be simply reproduced."
    end

    lines << "Constraints: a clear, readable silhouette, a strong visual hierarchy, intentional negative " \
             "space, and linework suited to being tattooed, as one coherent composition."
    lines << "Output: the tattoo design concept itself, clean linework on a plain background, meant to be " \
             "adapted by a professional tattoo artist. No tattooed person, no mockup on skin, no photo, no " \
             "frame, no watermark, and do not present it as a ready-to-use stencil."

    lines.join("\n\n")
  end

  def self.style_instruction(style_names)
    return "render it in #{style_names.first} tattoo style." if style_names.size == 1

    "combine #{style_names[0]} and #{style_names[1]} tattoo styles into a single cohesive design, not a " \
    "simple juxtaposition. Decide which of the two styles best serves as the structural foundation " \
    "(composition, shapes, readability, linework) and use the other as a complementary, expressive influence."
  end
end
