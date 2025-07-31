# frozen_string_literal: true

class AccredsController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index]
  before_action :load_and_authorize_accred, only: %i[show edit update]

  # GET /profile/profile_id/accreds or /profile/profile_id/accreds.json
  def index
    @accreds = Accred.for_profile!(@profile).sort { |a, b| a.position <=> b.position }
  end

  # GET /accreds/1 or /accreds/1.json
  def show; end

  # GET /accreds/1/edit
  def edit; end

  # PATCH/PUT /accreds/1 or /accreds/1.json
  def update
    respond_to do |format|
      if @accred.update(accred_params)
        format.turbo_stream do
          turbo_flash(:success)
          render :update
        end
        format.json { render :show, status: :ok, location: accred_path(@accred) }
      else
        format.turbo_stream do
          turbo_flash(:error)
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, accreds: @accred }
        end
        format.json { render json: @accred.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_and_authorize_accred
    @accred = Accred.includes(:profile).find(params[:id])
    @profile = @accred.profile
    @accreds_count = Accred.where(profile_id: @accred.profile_id).count
    authorize! @accred, to: :update?
  end

  def accred_params
    params.require(:accred).permit(
      :position,
      :visibility,
      :address_visibility
    )
  end
end
