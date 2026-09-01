class TattooGeneration < ApplicationRecord
  belongs_to :user
  has_many :body_previews, dependent: :nullify

  validates :prompt, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  REFERENCE_USE_FOR_INSTRUCTIONS = {
    "overall" => ->(n) {
      "Use Image #{n} as broad visual direction for the tattoo, while keeping the written concept above authoritative."
    },
    "composition" => ->(n) {
      "Use Image #{n} primarily for spatial arrangement, pose, orientation, proportions and composition. Do not " \
      "inherit unrelated subject matter, color palette, photographic realism or visual style from it."
    },
    "style" => ->(n) {
      "Use Image #{n} primarily for line treatment, shading, texture and overall visual aesthetic. Do not copy " \
      "unrelated subject matter or composition from it."
    },
    "element" => ->(n) {
      "Use Image #{n} as guidance for one specific subject, form or detail from the written concept above. Do " \
      "not treat the rest of the image as required direction."
    }
  }.freeze

  # Guided-mode prompt builder: deterministic string template, no extra LLM call.
  # reference_use_for is positionally aligned with the uploaded reference images
  # (Image 1 = reference_use_for[0], etc.) -- see ReferenceImagesController JS,
  # which renders one "Use for" <select> per thumbnail in upload order.
  def self.build_guided_prompt(idea:, style_names:, reference_count:, reference_use_for:, additional_guidance:)
    sections = []

    sections << "[CORE CONCEPT]\n#{idea}. This idea defines what the tattoo depicts and takes priority over " \
                "any other input below."

    sections << if style_names.any?
      "[TATTOO STYLE]\nRender the final tattoo in #{style_names.first} tattoo style. This style defines the " \
      "overall aesthetic of the finished design."
    else
      "[TATTOO STYLE]\nNo specific tattoo style was requested. Apply a professional, tattoo-appropriate design " \
      "treatment suited to the concept above -- clean, deliberate, and ready to be interpreted by a tattoo artist."
    end

    reference_count.times do |i|
      n = i + 1
      use_for = reference_use_for[i].presence || "overall"
      instruction = (REFERENCE_USE_FOR_INSTRUCTIONS[use_for] || REFERENCE_USE_FOR_INSTRUCTIONS["overall"]).call(n)
      sections << "[REFERENCE #{n} GUIDANCE]\n#{instruction}"
    end

    if additional_guidance.present?
      sections << "[ADDITIONAL GUIDANCE]\n#{additional_guidance}"
    end

    sections << "[TATTOO DESIGN CONSTRAINTS]\nA clear, readable silhouette, a strong visual hierarchy, " \
                "intentional negative space, and linework suited to being tattooed, as one coherent " \
                "composition. If any reference image conflicts with the core concept or the tattoo style " \
                "above, resolve it in favor of the core concept and style."

    sections << "[OUTPUT REQUIREMENTS]\nProduce the tattoo design concept itself, clean linework on a plain " \
                "background, meant to be adapted by a professional tattoo artist. No tattooed person, no " \
                "mockup on skin, no photo, no frame, no watermark, and do not present it as a ready-to-use " \
                "stencil."

    sections.join("\n\n")
  end
end
