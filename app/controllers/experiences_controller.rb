# frozen_string_literal: true

class ExperiencesController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_experience, only: %i[show edit update destroy]

  # GET /profile/profile_id/experiences or /profile/profile_id/experiences.json
  def index
    # sleep 2
    @experiences = @profile.experiences.order(:position)
  end

  # GET /experiences/1 or /experiences/1.json
  def show; end

  # GET /profile/profile_id/experiences/new
  def new
    @experience = @profile.experiences.new
  end

  # GET /experiences/1/edit
  def edit; end

  # POST /profile/profile_id/experiences or /profile/profile_id/experiences.json
  def create
    @experience = @profile.experiences.new(experience_params)
    if @experience.save
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /experiences/1 or /experiences/1.json
  def update
    if @experience.update(experience_params)
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /experiences/1 or /experiences/1.json
  def destroy
    @experience.destroy!
    turbo_flash(:success)
  end

  private

  def append_experience
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_experience",
                                             locals: { experience: @experience })
  end

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_experience
    @experience = Experience.includes(:profile).find(params[:id])
    authorize! @experience, to: :update?
  end

  # Only allow a list of trusted parameters through.
  def experience_params
    params.require(:experience).permit(
      :location, :title_fr, :title_en, :year_begin, :year_end,
      :visibility, :position, :description_fr, :description_en
    )
  end
end
