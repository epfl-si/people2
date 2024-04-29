# frozen_string_literal: true

class BoxesController < ApplicationController
  before_action :set_box, only: %i[show edit update destroy]

  # GET /boxes or /boxes.json
  def index
    @boxes = Box.all
  end

  # GET /boxes/1 or /boxes/1.json
  def show; end

  # GET /boxes/new
  def new
    @box = Box.new
  end

  # GET /boxes/1/edit
  def edit; end

  # POST /boxes or /boxes.json
  def create
    @box = Box.new(box_params)

    respond_to do |format|
      if @box.save
        format.html { redirect_to box_url(@box), notice: "Box was successfully created." }
        format.json { render :show, status: :created, location: @box }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boxes/1 or /boxes/1.json
  def update
    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to box_url(@box), notice: "Box was successfully updated." }
        format.json { render :show, status: :ok, location: @box }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boxes/1 or /boxes/1.json
  def destroy
    @box.destroy

    respond_to do |format|
      format.html { redirect_to boxes_url, notice: "Box was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_box
    @box = Box.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def box_params
    params.fetch(:box, {})
  end
end
