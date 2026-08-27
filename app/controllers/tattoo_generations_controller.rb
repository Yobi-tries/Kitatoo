class TattooGenerationsController < ApplicationController
  def new
  end

  def create
    prompt = params[:prompt].to_s.strip

    if prompt.blank?
      flash[:alert] = "Please describe the tattoo you want to generate."
      return redirect_to new_tattoo_generation_path
    end

    tattoo_generation = current_user.tattoo_generations.create!(prompt: prompt)
    TattooGenerationJob.perform_later(tattoo_generation.id)

    redirect_to tattoo_generation
  end

  def show
    @tattoo_generation = current_user.tattoo_generations.find(params[:id])
  end
end
