# frozen_string_literal: true

class InfosciencesController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_infoscience, only: %i[show edit update destroy]

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
    if @infoscience.save
      flash.now[:success] = ".create"
    else
      flash.now[:success] = ".create"
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /infosciences/1 or /infosciences/1.json
  def update
    if @infoscience.update(infoscience_params)
      flash.now[:success] = ".update"
    else
      flash.now[:error] = ".update"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /infosciences/1 or /infosciences/1.json
  def destroy
    @infoscience.destroy!
    flash.now[:success] = ".remove"
  end

  private

  def append_infoscience
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_infoscience",
                                             locals: { infoscience: @infoscience })
  end

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_infoscience
    @infoscience = Infoscience.includes(:profile).find(params[:id])
    authorize! @infoscience, to: :update?
  end

  # Only allow a list of trusted parameters through.
  def infoscience_params
    params.require(:infoscience).permit(
      :title_fr, :title_en, :title_it, :title_de, :url,
      :visibility, :position
    )
  end
end
