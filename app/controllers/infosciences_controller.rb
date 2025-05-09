# frozen_string_literal: true

class InfosciencesController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_infoscience, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/infosciences or /profile/profile_id/infosciences.json
  def index
    # sleep 2
    @infosciences = @profile.infosciences.order(:position)
  end

  # GET /infosciences/1 or /infosciences/1.json
  def show; end

  # GET /profile/profile_id/infosciences/new
  def new
    @infoscience = Infoscience.new
  end

  # GET /infosciences/1/edit
  def edit; end

  # POST /profile/profile_id/infosciences or /profile/profile_id/infosciences.json
  def create
    @infoscience = @profile.infosciences.new(infoscience_params)

    respond_to do |format|
      if @infoscience.save
        # format.html { append_infoscience }
        format.turbo_stream do
          flash.now[:success] = ".create"
          render :create, locals: { profile: @profile, infoscience: @infoscience }
        end
        format.json { render :show, status: :created, location: @infoscience }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:success] = ".create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, infoscience: @infoscience }
        end
        format.json { render json: @infoscience.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /infosciences/1 or /infosciences/1.json
  def update
    respond_to do |format|
      if @infoscience.update(infoscience_params)
        format.turbo_stream do
          flash.now[:success] = ".update"
          render :update
        end
        format.json { render :show, status: :ok, location: @infoscience }
      else
        format.turbo_stream do
          flash.now[:error] = ".update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, infoscience: @infoscience }
        end
        format.json { render json: @infoscience.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /infosciences/1 or /infosciences/1.json
  def destroy
    @infoscience.destroy!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = ".remove"
        render :destroy
      end
      format.json { head :no_content }
    end
  end

  def toggle
    respond_to do |format|
      if @infoscience.update(visible: !@infoscience.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @infoscience }
      else
        format.turbo_stream do
          flash.now[:error] = ".update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @infoscience.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def append_infoscience
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_infoscience",
                                             locals: { infoscience: @infoscience })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_infoscience
    @infoscience = Infoscience.includes(:profile).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def infoscience_params
    params.require(:infoscience).permit(
      :title_fr, :title_en, :title_it, :title_de, :url,
      :visibility, :position
    )
  end
end
