# frozen_string_literal: true

class AchievementsController < BackendController
  before_action :set_profile, only: %i[index create new]
  before_action :set_achievement, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/achievements or /profile/profile_id/achievements.json
  def index
    # sleep 2
    @achievements = @profile.achievements.order(:position)
  end

  # GET /achievements/1 or /achievements/1.json
  def show; end

  # GET /profile/profile_id/achievements/new
  def new
    @achievement = achievement.new
  end

  # GET /achievements/1/edit
  def edit; end

  # POST /profile/profile_id/achievements or /profile/profile_id/achievements.json
  def create
    @achievement = @profile.achievements.new(achievement_params)

    respond_to do |format|
      if @achievement.save
        # format.html { append_achievement }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.create"
          render :create, locals: { profile: @profile, achievement: @achievement }
        end
        format.json { render :show, status: :created, location: @achievement }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.error.create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, achievement: @achievement }
        end
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /achievements/1 or /achievements/1.json
  def update
    respond_to do |format|
      if @achievement.update(achievement_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @achievement }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, achievement: @achievement }
        end
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /achievements/1 or /achievements/1.json
  def destroy
    @achievement.destroy!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = "flash.generic.success.remove"
        render :destroy
      end
      format.json { head :no_content }
    end
  end

  def toggle
    respond_to do |format|
      if @achievement.update(visible: !@achievement.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @achievement }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def append_achievement
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_achievement",
                                             locals: { achievement: @achievement })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_achievement
    @achievement = achievement.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def achievement_params
    params.require(:achievement).permit(
      :year,
      :description_fr, :description_en, :description_it, :description_de,
      :audience, :visible, :position
    )
  end
end
