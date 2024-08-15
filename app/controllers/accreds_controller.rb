# frozen_string_literal: true

class AccredsController < BackendController
  before_action :set_profile, only: %i[index]
  before_action :set_accred, only: %i[show edit update toggle toggle_addr]

  # GET /profile/profile_id/accreds or /profile/profile_id/accreds.json
  def index
    # sleep 2
    @accreds = @profile.accreds
    @accreds = Accred.for_profile!(@profile).sort if @accreds.empty?
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
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: accred_path(@accred) }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, accreds: @accred }
        end
        format.json { render json: @accred.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accreds/1/toggle or /accreds/1/toggle.json
  def toggle
    respond_to do |format|
      if @accred.update(visible: !@accred.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @accred }
      else
        # revert
        @accred.visible = !@accred.visible?
        format.turbo_stream do
          flash.now[:error] = "flash.accred.cannot_hide_all"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @accred.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accreds/1/toggle_address or /accreds/1/toggle_address.json
  def toggle_addr
    respond_to do |format|
      if @accred.update(visible_addr: !@accred.visible_addr?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @accred }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @accred.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_accred
    @accred = Accred.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def accred_params
    params.require(:accred).permit(
      :position,
      :visible,
      :visible_addr
    )
  end
end
