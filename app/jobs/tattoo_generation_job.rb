class TattooGenerationJob < ApplicationJob
  queue_as :default

  def perform(tattoo_generation_id)
    tattoo_generation = TattooGeneration.find(tattoo_generation_id)

    image = RubyLLM.paint(tattoo_generation.prompt, model: "gpt-image-1")

    upload = Cloudinary::Uploader.upload(
      StringIO.new(image.to_blob),
      content_type: image.mime_type,
      original_filename: "tattoo-generation-#{tattoo_generation.id}.png"
    )

    tattoo_generation.update!(
      status: :completed,
      image_url: upload["secure_url"],
      image_public_id: upload["public_id"]
    )
  rescue RubyLLM::Error, Cloudinary::CloudinaryException => e
    tattoo_generation.update!(status: :failed)
    Rails.logger.error("TattooGenerationJob failed for ##{tattoo_generation_id}: #{e.message}")
  ensure
    if tattoo_generation
      Turbo::StreamsChannel.broadcast_replace_to(
        tattoo_generation,
        target: "tattoo_generation_result",
        partial: "tattoo_generations/result",
        locals: { tattoo_generation: tattoo_generation }
      )
    end
  end
end
