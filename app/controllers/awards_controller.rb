# frozen_string_literal: true

class AwardsController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_award, only: %i[show edit update destroy]

  # GET /profile/profile_id/awards or /profile/profile_id/awards.json
  def index
    @awards = @profile.awards.order(:position)
  end

  # GET /awards/1 or /awards/1.json
  def show; end

  # GET /profile/profile_id/awards/new
  def new
    @award = @profile.awards.new(category_id: Award.default_category&.id, origin_id: Award.default_origin&.id)
  end

  # GET /awards/1/edit
  def edit; end

  # POST /profile/profile_id/awards or /profile/profile_id/awards.json
  def create
    @award = @profile.awards.new(award_params)
    if @award.save
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /awards/1 or /awards/1.json
  def update
    if @award.update(award_params)
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /awards/1 or /awards/1.json
  def destroy
    @award.destroy!
    turbo_flash(:success)
  end

  private

  def append_award
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_award",
                                             locals: { award: @award })
  end

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_award
    @award = Award.includes(:profile).find(params[:id])
    authorize! @award, to: :update?
  end

  # Only allow a list of trusted parameters through.
  def award_params
    params.require(:award).permit(
      :location, :title_fr, :title_en, :title_it, :title_de, :year, :issuer,
      :visibility, :position, :origin_id, :category_id
    )
  end
end
