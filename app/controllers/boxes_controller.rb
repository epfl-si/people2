# frozen_string_literal: true

class BoxesController < ApplicationController
  before_action :load_and_authorize_profile, only: %i[index create new]
  before_action :load_and_authorize_box, only: %i[show edit update destroy]

  # GET /profiles/:profile_id/sections/:section_id/boxes
  def index
    @section = Section.find(params.require(:section_id))
    @boxes = @profile.boxes.includes(:section).where(section_id: @section.id).order(:position)
    @optional_boxes = @profile.available_optional_boxes(@section)
  end

  # GET /boxes/1 or /boxes/1.json
  def show; end

  # GET /boxes/new
  # This action is called when we create boxes that can be edited right away
  # as it is the case for text boxes.
  def new
    # TODO: raise error if mbid is not provided
    mbid = params.require(:model_box_id)
    @mbox = ModelBox.find(mbid)
    # ensure the number of boxes does not overgrow
    if @profile.boxes.where(model_box_id: mbid).count < @mbox.max_copies
      @box = Box.from_model(@mbox)
      @box.profile = @profile
    else
      unexpected "Unexpected. Asking to add a new box when max number already reached"
    end
  end

  # GET /boxes/1/edit
  def edit; end

  # POST /profile/:profile_id/boxes or /profile/:profile_id/boxes.json
  # For Index boxes instead we need the box to be already present before adding
  # content. Therefore the box is created on the fly.
  def create
    mbid = params.require(box_symbol).require(:model_box_id)
    # mbid = box_params(:create).require(:model_box_id)
    @mbox = ModelBox.find(mbid)

    # double check that we are not asked to create more boxed than allowed
    if @profile.boxes.where(model_box_id: mbid).count >= @mbox.max_copies
      unexpected "Unexpected. Asking to create a new box when max number already reached"
      return
    end

    @box = Box.from_model(@mbox, box_params)
    @box.profile = @profile
    if @box.save
      @section = @box.section
      @optional_boxes = @profile.available_optional_boxes(@section)
      turbo_flash_render(:success)
    else
      turbo_flash_render(:error)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /boxes/1 or /boxes/1.json
  def update
    respond_to do |format|
      Rails.logger.debug("update: box_params=#{box_params.inspect}")
      if @box.update(box_params)
        format.turbo_stream do
          turbo_flash(:success)
          render :update
        end
        format.json { render :show, status: :ok, location: @box }
      else
        format.turbo_stream do
          turbo_flash(:error)
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, award: @award }
        end
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boxes/1 or /boxes/1.json
  def destroy
    if @box.user_destroyable?
      @profile = @box.profile
      respond_to do |format|
        if @box.destroy

          @section = @box.section
          @optional_boxes = @profile.available_optional_boxes(@section)
          format.turbo_stream do
            turbo_flash(:success)
          end
          format.json { head :no_content }
        else
          format.turbo_stream do
            turbo_flash_render(:error)
          end
          format.json { render json: { error: msg }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          turbo_flash_render(:error)
        end
        format.json { render json: { error: msg }, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def load_and_authorize_box
    @box = Box.includes(:profile, :model).find(params[:id])
    authorize! @box, to: :update?
  end

  # This needs to be overridden to add box-specific acceptable parameters
  def extra_plist
    []
  end

  def box_symbol
    :box
  end

  # Only allow a list of trusted parameters through.
  def box_params(action = nil)
    plist = %i[visibility position]
    # plist << :model_box_id if action == :create || action == :new
    plist << extra_plist
    Rails.logger.debug("box_params for action = '#{action.inspect}': #{plist.join(',')}")
    params.require(box_symbol).permit(plist)
  end
end
