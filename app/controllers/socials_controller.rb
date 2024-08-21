# frozen_string_literal: true

class SocialsController < ApplicationController
  include SocialsHelper
  before_action :set_profile, only: %i[index create new]
  before_action :set_social, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/socials or /profile/profile_id/socials.json
  def index
    @socials = @profile.socials.order(:position)
  end

  # GET /socials/1 or /socials/1.json
  def show; end

  # GET /profile/profile_id/socials/new
  def new
    @social = Social.new
  end

  # GET /socials/1/edit
  def edit; end

  # POST /profile/profile_id/socials or /profile/profile_id/socials.json
  def create
    @social = @profile.socials.new(social_params)

    respond_to do |format|
      if @social.save
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.create"
          render :create, locals: { profile: @profile, social: @social }
        end
        format.json { render :show, status: :created, location: @social }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, social: @social }
        end
        format.json { render json: @social.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /socials/1 or /socials/1.json
  def update
    respond_to do |format|
      if @social.update(social_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @social }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, social: @social }
        end
        format.json { render json: @social.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /socials/1 or /socials/1.json
  def destroy
    @social.destroy!

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
      if @social.update(visible: !@social.visible?)
        format.turbo_stream do
          render :update
        end
        format.json { render :show, status: :ok, location: @social }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :update, status: :unprocessable_entity
        end
        format.json { render json: @social.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def social_params
    params.require(:social).permit(:tag, :value, :audience)
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_social
    @social = Social.find(params[:id])
  end
end
