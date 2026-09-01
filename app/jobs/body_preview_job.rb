class BodyPreviewJob < ApplicationJob
  queue_as :default

  def perform(body_preview_id)
    body_preview = BodyPreview.find(body_preview_id)

    image = RubyLLM.paint(
      BodyPreview.build_prompt,
      model: "gpt-image-1",
      with: [ body_preview.body_image_url, body_preview.source_image_url ],
      params: { input_fidelity: "high" }
    )

    upload = Cloudinary::Uploader.upload(
      StringIO.new(image.to_blob),
      content_type: image.mime_type,
      original_filename: "body-preview-#{body_preview.id}.png"
    )

    body_preview.update!(
      status: :completed,
      preview_image_url: upload["secure_url"],
      preview_image_public_id: upload["public_id"]
    )
  rescue RubyLLM::Error, RubyLLM::UnsupportedAttachmentError, CloudinaryException => e
    body_preview.update!(status: :failed)
    Rails.logger.error("BodyPreviewJob failed for ##{body_preview_id}: #{e.message}")
  ensure
    if body_preview
      Turbo::StreamsChannel.broadcast_replace_to(
        [ body_preview.user, :body_previews ],
        target: "body_preview_result",
        partial: "body_previews/result",
        locals: { body_preview: body_preview }
      )
    end
  end
end
