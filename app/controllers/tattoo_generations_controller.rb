class TattooGenerationsController < ApplicationController
  MAX_REFERENCE_IMAGES = 3

  def new
  end

  def create
    prompt, error = build_prompt
    return render_prompt_error(error) if error

    reference_urls, reference_public_ids = upload_reference_images

    tattoo_generation = current_user.tattoo_generations.create!(
      prompt: prompt,
      reference_image_urls: reference_urls,
      reference_image_public_ids: reference_public_ids
    )
    TattooGenerationJob.perform_later(tattoo_generation.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tattoo_generation_result",
          partial: "tattoo_generations/result",
          locals: { tattoo_generation: tattoo_generation }
        )
      end
      format.html { redirect_to tattoo_generation }
    end
  end

  def show
    @tattoo_generation = current_user.tattoo_generations.find(params[:id])
  end

  private

  def build_prompt
    idea = params[:idea].to_s.strip
    return [ nil, "Please describe your tattoo idea." ] if idea.blank?

    style_tags = Tag.where(id: Array(params[:style_tag_ids]).first(1)).to_a
    files = reference_image_files

    prompt = TattooGeneration.build_guided_prompt(
      idea: idea,
      style_names: style_tags.map(&:name),
      reference_count: files.size,
      reference_use_for: Array(params[:reference_use_for]).first(MAX_REFERENCE_IMAGES),
      additional_guidance: params[:reference_instruction].to_s.strip.presence
    )
    [ prompt, nil ]
  end

  def reference_image_files
    Array(params[:reference_images]).reject(&:blank?).first(MAX_REFERENCE_IMAGES)
  end

  def upload_reference_images
    files = reference_image_files
    return [ [], [] ] if files.blank?

    uploads = files.filter_map do |file|
      next unless file.respond_to?(:tempfile) && file.content_type.to_s.start_with?("image/")

      Cloudinary::Uploader.upload(file.tempfile.path)
    end

    [ uploads.map { |u| u["secure_url"] }, uploads.map { |u| u["public_id"] } ]
  end

  def render_prompt_error(message)
    locals = {
      error: message,
      idea: params[:idea],
      selected_style_ids: Array(params[:style_tag_ids]),
      reference_instruction: params[:reference_instruction]
    }

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tattoo_generation_result",
          partial: "tattoo_generations/create_form",
          locals: locals
        )
      end
      format.html do
        flash[:alert] = message
        redirect_to new_tattoo_generation_path
      end
    end
  end
end
