# frozen_string_literal: true

class BoxesController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_box, only: %i[show edit update destroy toggle]

  # GET /profiles/:profile_id/sections/:section_id/boxes
  def index
    @section = Section.find(params.require(:section_id))
    @boxes = @profile.boxes.includes(:section).where(section_id: @section.id).order(:position)
    @optional_boxes = @profile.available_optional_boxes(@section)
  end

  # GET /boxes/1 or /boxes/1.json
  def show; end

  # GET /boxes/new
  def new
    # TODO: raise error if mbid is not provided
    mbid = params.require(:model_box_id)
    @mbox = ModelBox.find(mbid)
    # ensure the number of boxes does not overgrow
    if @profile.boxes.where(model_box_id: mbid).count < @mbox.max_copies
      @box = Box.from_model(@mbox)
    else
      respond_to do |format|
        format.html { head :forbidden }
        format.json { render json: { msg: "Max number of boxes reached" }, status: :forbidden }
      end
    end
  end

  # GET /boxes/1/edit
  def edit; end

  # POST /profile/:profile_id/boxes or /profile/:profile_id/boxes.json
  def create
    mbid = box_params(:create).require(:model_box_id)
    @mbox = ModelBox.find(mbid)

    if @profile.boxes.where(model_box_id: mbid).count >= @mbox.max_copies
      raise "Unexpected. Asking to create a new box when max number already reached"
    end

    @box = Box.from_model(@mbox, box_params)
    @box.profile = @profile
    ok = @box.save
    if ok
      @section = @box.section
      @optional_boxes = @profile.available_optional_boxes(@section)
      flash.now[:success] = "flash.generic.success.create"
    end
    return if ok

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = "flash.generic.error.create"
        render :new, status: :unprocessable_entity
      end
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @box.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /boxes/1 or /boxes/1.json
  def update
    respond_to do |format|
      if @box.update(box_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @box }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
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
          flash.now[:success] = "flash.box.success.deleted"
          @section = @box.section
          @optional_boxes = @profile.available_optional_boxes(@section)
          format.turbo_stream
          format.json { head :no_content }
        else
          msg = "flash.box.error.destroy_unexpectedly_failed"
          format.turbo_stream do
            flash.now[:error] = msg
            turbo_stream.replace("flash-messages", partial: "shared/flash")
          end
          format.json { render json: { error: msg }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        msg = "flash.box.error.cannot_delete"
        format.turbo_stream do
          flash.now[:error] = msg
          turbo_stream.replace("flash-messages", partial: "shared/flash")
        end
        format.json { render json: { error: msg }, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    respond_to do |format|
      if @box.update(visible: !@box.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @box }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_profile
    @profile = Profile.find(params.require(:profile_id))
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = Box.includes(:profile, :model).find(params[:id])
  end

  def extra_plist
    []
  end

  def box_symbol
    :box
  end

  # Only allow a list of trusted parameters through.
  def box_params(action = nil)
    plist = %i[visibility position]
    unless action.nil?
      case action
      when :create
        plist << :model_box_id
      end
    end
    plist += extra_plist
    params.require(box_symbol).permit(plist)
  end
end
