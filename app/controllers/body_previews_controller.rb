class BodyPreviewsController < ApplicationController
  def create
    design_url, design_public_id = resolve_design_image
    return render_error("Please choose a tattoo design (generated or uploaded).") if design_url.blank?

    body_url, body_public_id = resolve_body_image
    return render_error("Please upload a photo of your body.") if body_url.blank?

    placement = resolve_placement
    return render_error("Please choose a placement.") if placement.blank?

    body_preview = current_user.body_previews.create!(
      tattoo_generation_id: source_generation&.id,
      placement: placement,
      source_image_url: design_url,
      source_image_public_id: design_public_id,
      body_image_url: body_url,
      body_image_public_id: body_public_id
    )
    BodyPreviewJob.perform_later(body_preview.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "body_preview_result",
          partial: "body_previews/result",
          locals: { body_preview: body_preview }
        )
      end
      format.html { redirect_to new_tattoo_generation_path }
    end
  end

  private

  def source_generation
    return @source_generation if defined?(@source_generation)

    @source_generation = params[:tattoo_generation_id].presence &&
      current_user.tattoo_generations.completed.find_by(id: params[:tattoo_generation_id])
  end

  def resolve_design_image
    return [ source_generation.image_url, source_generation.image_public_id ] if source_generation

    upload_image_param(:design_image)
  end

  def resolve_body_image
    upload_image_param(:body_photo)
  end

  def upload_image_param(key)
    file = params[key]
    return [ nil, nil ] unless file.respond_to?(:tempfile) && file.content_type.to_s.start_with?("image/")

    upload = Cloudinary::Uploader.upload(file.tempfile.path)
    [ upload["secure_url"], upload["public_id"] ]
  end

  def resolve_placement
    raw = params[:placement].to_s
    raw == "Other" ? params[:placement_other].to_s.strip.presence : raw.presence
  end

  def render_error(message)
    locals = { error: message, placement: params[:placement], placement_other: params[:placement_other],
               tattoo_generation_id: params[:tattoo_generation_id] }

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "body_preview_form",
          partial: "body_previews/form",
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
