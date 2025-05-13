# frozen_string_literal: true

class ExperiencesController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_experience, only: %i[show edit update destroy]

  # GET /profile/profile_id/experiences or /profile/profile_id/experiences.json
  def index
    # sleep 2
    @experiences = @profile.experiences.order(:position)
  end

  # GET /experiences/1 or /experiences/1.json
  def show; end

  # GET /profile/profile_id/experiences/new
  def new
    @experience = Experience.new
  end

  # GET /experiences/1/edit
  def edit; end

  # POST /profile/profile_id/experiences or /profile/profile_id/experiences.json
  def create
    @experience = @profile.experiences.new(experience_params)
    if @experience.save
      flash.now[:success] = ".create"
    else
      flash.now[:success] = ".create"
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /experiences/1 or /experiences/1.json
  def update
    if @experience.update(experience_params)
      flash.now[:success] = ".update"
    else
      flash.now[:error] = ".update"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /experiences/1 or /experiences/1.json
  def destroy
    @experience.destroy!
    flash.now[:success] = ".remove"
  end

  private

  def append_experience
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_experience",
                                             locals: { experience: @experience })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_experience
    @experience = Experience.includes(:profile).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def experience_params
    params.require(:experience).permit(
      :location, :title_fr, :title_en, :year_begin, :year_end,
      :visibility, :position, :description_fr, :description_en
    )
  end
end
