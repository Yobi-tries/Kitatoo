class TattooGenerationsController < ApplicationController
  MAX_REFERENCE_IMAGES = 3

  def new
  end

  def create
    prompt, error = build_prompt

    if error
      return render_prompt_error(error)
    end

    reference_urls, reference_public_ids = upload_reference_images

    tattoo_generation = current_user.tattoo_generations.create!(
      prompt: prompt,
      reference_image_urls: reference_urls,
      reference_image_public_ids: reference_public_ids
    )
    TattooGenerationJob.perform_later(tattoo_generation.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "tattoo_generation_result",
            partial: "tattoo_generations/result",
            locals: { tattoo_generation: tattoo_generation, in_drawer: true }
          ),
          turbo_stream.replace(
            "tattoo_generation_badge",
            partial: "tattoo_generations/robot_badge",
            locals: { tattoo_generation: tattoo_generation }
          )
        ]
      end
      format.html { redirect_to tattoo_generation }
    end
  end

  def show
    @tattoo_generation = current_user.tattoo_generations.find(params[:id])
  end

  private

  def guided_mode?
    params[:mode] == "guided"
  end

  def build_prompt
    guided_mode? ? build_guided_prompt : build_free_text_prompt
  end

  def build_free_text_prompt
    prompt = params[:prompt].to_s.strip
    prompt.present? ? [ prompt, nil ] : [ nil, "Please describe the tattoo you want to generate." ]
  end

  def build_guided_prompt
    idea = params[:idea].to_s.strip
    return [ nil, "Please describe your tattoo idea." ] if idea.blank?

    style_tags = Tag.where(id: Array(params[:style_tag_ids]).first(2)).to_a
    return [ nil, "Please select at least one style." ] if style_tags.empty?

    placement = resolve_placement
    return [ nil, "Please choose a placement." ] if placement.blank?

    prompt = TattooGeneration.build_guided_prompt(
      idea: idea,
      style_names: style_tags.map(&:name),
      placement: placement,
      has_references: reference_image_files.present?
    )
    [ prompt, nil ]
  end

  def resolve_placement
    raw = params[:placement].to_s
    raw == "Other" ? params[:placement_other].to_s.strip.presence : raw.presence
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
      mode: guided_mode? ? "guided" : "free_text",
      idea: params[:idea],
      selected_style_ids: Array(params[:style_tag_ids]),
      placement: params[:placement],
      placement_other: params[:placement_other],
      free_text_prompt: params[:prompt]
    }

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tattoo_generation_result",
          partial: "tattoo_generations/drawer_form",
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
