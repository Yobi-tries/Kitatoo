class TattooGeneration < ApplicationRecord
  belongs_to :user
  has_many :body_previews, dependent: :nullify

  validates :prompt, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  # Guided-mode prompt builder: deterministic string template, no extra LLM call.
  # style_names keeps whatever order the caller selected them in -- this method never
  # decides which one is "primary"; that decision is explicitly delegated to the image
  # model itself via the wording of style_instruction below.
  def self.build_guided_prompt(idea:, style_names:, has_references:, reference_instruction: nil)
    lines = []
    lines << "You are creating an original tattoo design concept, not a photo or a finished tattoo on skin."
    lines << "Subject: #{idea}"
    lines << "Style: #{style_instruction(style_names)}"

    if has_references
      lines << reference_instruction_line(reference_instruction)
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

  def self.reference_instruction_line(instruction)
    base = "References: the attached reference image(s) are a strong visual direction for this design"
    base += ", specifically for #{instruction}" if instruction.present?
    "#{base}. Let them meaningfully shape the composition, shapes and visual language of the result -- the " \
    "subject above still defines what the tattoo represents, but the references should be clearly reflected " \
    "in how it looks, not just loosely inspire it. Do not simply reproduce them as-is."
  end
end
