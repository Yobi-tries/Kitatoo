class TattooGeneration < ApplicationRecord
  belongs_to :user
  has_many :body_previews, dependent: :nullify

  validates :prompt, presence: true

  enum :status, { pending: 0, completed: 1, failed: 2 }

  scope :unnotified, -> {
    completed.where(viewed_at: nil).where.not(image_url: [ nil, "" ]).where.not(image_public_id: [ nil, "" ])
  }

  def mark_viewed!
    return if viewed_at.present?

    update_column(:viewed_at, Time.current)
    broadcast_notification_badge
  end

  def broadcast_notification_badge
    Turbo::StreamsChannel.broadcast_replace_to(
      "notifications_#{user_id}",
      target: "tattoo-generator-notification-badge",
      partial: "shared/tattoo_generator_badge",
      locals: { user: user }
    )
  end

  REFERENCE_GUIDANCE = "Use the supplied reference image(s) as visual guidance for the subject, composition, " \
                       "shapes and relevant visual details. Adapt them into the requested tattoo design and " \
                       "selected tattoo style. Do not reproduce photographic backgrounds, lighting, skin or " \
                       "irrelevant elements."

  # Guided-mode prompt builder: deterministic string template, no extra LLM call.
  def self.build_guided_prompt(idea:, style_names:, reference_count:)
    sections = []

    sections << if idea.present?
                  "[CORE CONCEPT]\n#{idea}. This idea defines what the tattoo depicts and takes priority over any other " \
                    "input below."
                else
                  "[CORE CONCEPT]\nNo written concept was provided. Use the reference image(s) below as the primary source " \
                    "for the tattoo's subject and composition."
                end

    sections << if style_names.any?
                  "[TATTOO STYLE]\nRender the final tattoo in #{style_names.first} tattoo style. This style defines the " \
                    "overall aesthetic of the finished design."
                else
                  "[TATTOO STYLE]\nNo specific tattoo style was requested. Apply a professional, tattoo-appropriate design " \
                    "treatment suited to the concept above -- clean, deliberate, and ready to be interpreted by a tattoo artist."
                end

    sections << "[REFERENCE GUIDANCE]\n#{REFERENCE_GUIDANCE}" if reference_count.positive?

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
