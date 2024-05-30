# frozen_string_literal: true

class AwardsController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_award, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/awards or /profile/profile_id/awards.json
  def index
    # sleep 2
    @awards = @profile.awards.order(:position)
  end

  # GET /awards/1 or /awards/1.json
  def show; end

  # GET /profile/profile_id/awards/new
  def new
    @award = Award.new
  end

  # GET /awards/1/edit
  def edit; end

  # POST /profile/profile_id/awards or /profile/profile_id/awards.json
  def create
    @award = @profile.awards.new(award_params)

    respond_to do |format|
      if @award.save
        # format.html { append_award }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.create"
          render :create, locals: { profile: @profile, award: @award }
        end
        format.json { render :show, status: :created, location: @award }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:success] = "flash.generic.error.create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, award: @award }
        end
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /awards/1 or /awards/1.json
  def update
    respond_to do |format|
      if @award.update(award_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @award }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, award: @award }
        end
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /awards/1 or /awards/1.json
  def destroy
    @award.destroy!

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
      if @award.update(visible: !@award.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @award }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def append_award
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_award",
                                             locals: { award: @award })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_award
    @award = Award.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def award_params
    params.require(:award).permit(
      :location, :title_fr, :title_en, :year, :issuer,
      :audience, :visible, :position
    )
  end
end
