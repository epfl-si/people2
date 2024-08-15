# frozen_string_literal: true

class EducationsController < BackendController
  before_action :set_profile, only: %i[index create new]
  before_action :set_education, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/educations or /profile/profile_id/educations.json
  def index
    # sleep 2
    @educations = @profile.educations.order(:position)
  end

  # GET /educations/1 or /educations/1.json
  def show; end

  # GET /profile/profile_id/educations/new
  def new
    @education = Education.new
  end

  # GET /educations/1/edit
  def edit; end

  # POST /profile/profile_id/educations or /profile/profile_id/educations.json
  def create
    @education = @profile.educations.new(education_params)

    respond_to do |format|
      if @education.save
        # format.html { append_education }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.create"
          render :create, locals: { profile: @profile, education: @education }
        end
        format.json { render :show, status: :created, location: @education }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.error.create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, education: @education }
        end
        format.json { render json: @education.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /educations/1 or /educations/1.json
  def update
    respond_to do |format|
      if @education.update(education_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @education }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, education: @education }
        end
        format.json { render json: @education.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /educations/1 or /educations/1.json
  def destroy
    @education.destroy!

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
      if @education.update(visible: !@education.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @education }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @education.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def append_education
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_education",
                                             locals: { education: @education })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_education
    @education = Education.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def education_params
    params.require(:education).permit(
      :title_en, :title_fr, :field_en, :field_fr, :director, :school,
      :year_begin, :year_end, :position, :audience, :visible, :description_fr, :description_en
    )
  end
end
