# frozen_string_literal: true

class SocialsController < ApplicationController
  include SocialsHelper
  before_action :set_profile, only: %i[index create new]
  before_action :set_socials, only: %i[index create]
  before_action :set_social, only: %i[show edit update destroy toggle]

  # GET /profile/profile_id/socials or /profile/profile_id/socials.json
  def index; end

  # GET /socials/1 or /socials/1.json
  def show; end

  # GET /profile/profile_id/socials/new
  def new
    tag = params[:tag]
    if tag.present?
      new_step2(tag)
    else
      new_step1
    end
  end

  def new_step1
    set_socials
    respond_to do |format|
      format.turbo_stream do
        render :new_step1
      end
    end
  end

  def new_step2(tag)
    unless Social.tag?(tag)
      # TODO: return useful error to user
      raise "Invalid social tag"
    end

    @social = Social.new(tag: tag)
    respond_to do |format|
      if @social.automatic?
        @social.profile = @profile
        if @social.save
          # need to call it here otherwise it incomplete
          set_socials
          format.turbo_stream do
            flash.now[:success] = "flash.generic.success.create"
            render :create
          end
        else
          format.turbo_stream do
            flash.now[:error] = "flash.generic.error.create"
            render :new_step2, status: :unprocessable_entity, locals: { profile: @profile, social: @social }
          end
        end
      else
        format.turbo_stream do
          render :new_step2, locals: { profile: @profile, social: @social }
        end
      end
    end
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
    @profile = @social.profile
    @social.destroy!

    set_socials
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
    params.require(:social).permit(:tag, :value, :visibility)
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_socials
    @socials = @profile.socials.order(:position)
    @tag_selector = Social.remaining(@socials).map { |s| [s[:label], s[:tag]] }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_social
    @social = Social.includes(:profile).find(params[:id])
    @profile = @social.profile
  end
end
