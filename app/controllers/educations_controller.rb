# frozen_string_literal: true

class EducationsController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_education, only: %i[show edit update destroy]

  # GET /profile/profile_id/educations or /profile/profile_id/educations.json
  def index
    @educations = @profile.educations.order(:position)
  end

  # GET /educations/1 or /educations/1.json
  def show; end

  # GET /profile/profile_id/educations/new
  def new
    o = Education.categories.where(label: 'other').first
    @education = @profile.educations.new(category: o)
  end

  # GET /educations/1/edit
  def edit; end

  # POST /profile/profile_id/educations or /profile/profile_id/educations.json
  def create
    @education = @profile.educations.new(education_params)
    if @education.save
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /educations/1 or /educations/1.json
  def update
    if @education.update(education_params)
      turbo_flash(:success)
    else
      turbo_flash(:success)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /educations/1 or /educations/1.json
  def destroy
    @education.destroy!
    turbo_flash(:success)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_education
    @education = Education.includes(:profile).find(params[:id])
    authorize! @education, to: :update?
  end

  # Only allow a list of trusted parameters through.
  def education_params
    params.require(:education).permit(
      :title_en, :title_fr, :field_en, :field_fr, :director, :school,
      :year_begin, :year_end, :position, :visibility, :description_fr, :description_en,
      :category_id
    )
  end
end
