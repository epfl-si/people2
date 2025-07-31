# frozen_string_literal: true

class AchievementsController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_achievement, only: %i[show edit update destroy]

  # GET /profile/profile_id/achievements or /profile/profile_id/achievements.json
  def index
    @achievements = @profile.achievements.order(:position)
  end

  # GET /achievements/1 or /achievements/1.json
  def show; end

  # GET /profile/profile_id/achievements/new
  def new
    @achievement = @profile.achievements.new
  end

  # GET /achievements/1/edit
  def edit; end

  # POST /profile/profile_id/achievements or /profile/profile_id/achievements.json
  def create
    @achievement = @profile.achievements.new(achievement_params)

    if @education.save
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /achievements/1 or /achievements/1.json
  def update
    if @achievement.update(achievement_params)
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /achievements/1 or /achievements/1.json
  def destroy
    @achievement.destroy!
    turbo_flash(:success)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_achievement
    @achievement = Achievement.includes(:profile).find(params[:id])
    authorize! @achievement, to: :update?
  end

  # Only allow a list of trusted parameters through.
  def achievement_params
    params.require(:achievement).permit(
      :year, :category_id, :url,
      :description_fr, :description_en, :description_it, :description_de,
      :visibility, :position
    )
  end
end
