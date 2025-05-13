# frozen_string_literal: true

class AwardsController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_award, only: %i[show edit update destroy]

  # GET /profile/profile_id/awards or /profile/profile_id/awards.json
  def index
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
    if @award.save
      flash.now[:success] = ".create"
    else
      flash.now[:success] = ".create"
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /awards/1 or /awards/1.json
  def update
    if @award.update(award_params)
      flash.now[:success] = ".update"
    else
      flash.now[:error] = ".update"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /awards/1 or /awards/1.json
  def destroy
    @award.destroy!
    flash.now[:success] = ".remove"
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
    @award = Award.includes(:profile).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def award_params
    params.require(:award).permit(
      :location, :title_fr, :title_en, :title_it, :title_de, :year, :issuer,
      :visibility, :position, :origin_id, :category_id
    )
  end
end
