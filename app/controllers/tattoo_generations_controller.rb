class TattooGenerationsController < ApplicationController
  def new
  end

  def create
    prompt = params[:prompt].to_s.strip

    if prompt.blank?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "tattoo_generation_result",
            partial: "tattoo_generations/drawer_form",
            locals: { error: "Please describe the tattoo you want to generate." }
          )
        end
        format.html do
          flash[:alert] = "Please describe the tattoo you want to generate."
          redirect_to new_tattoo_generation_path
        end
      end
      return
    end

    tattoo_generation = current_user.tattoo_generations.create!(prompt: prompt)
    TattooGenerationJob.perform_later(tattoo_generation.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tattoo_generation_result",
          partial: "tattoo_generations/result",
          locals: { tattoo_generation: tattoo_generation, in_drawer: true }
        )
      end
      format.html { redirect_to tattoo_generation }
    end
  end

  def show
    @tattoo_generation = current_user.tattoo_generations.find(params[:id])
  end
end
