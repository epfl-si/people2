# frozen_string_literal: true

class SocialsController < ApplicationController
  include SocialsHelper
  before_action :set_profile, only: %i[index create new]
  before_action :set_social, only: %i[show edit update destroy]

  # GET /profile/profile_id/socials or /profile/profile_id/socials.json
  def index
    set_socials
  end

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
    render :new_step1
  end

  def new_step2(tag)
    unless Social.tag?(tag)
      # TODO: return useful error to user
      raise "Invalid social tag"
    end

    @social = Social.new(tag: tag)
    if @social.automatic?
      @social.profile = @profile
      if @social.save
        set_socials
        flash.now[:success] = ".create"
        render :create
      else
        flash.now[:error] = ".create"
        render :new_step2, status: :unprocessable_entity
      end
    else
      render :new_step2
    end
  end

  # GET /socials/1/edit
  def edit
    render nothing: true, status: :forbidden
  end

  # POST /profile/profile_id/socials or /profile/profile_id/socials.json
  def create
    @social = @profile.socials.new(social_params)
    if @social.save
      set_socials
      flash.now[:success] = ".create"
    else
      flash.now[:error] = ".create"
      render :new_step2, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /socials/1 or /socials/1.json
  def update
    if @social.update(social_params)
      flash.now[:success] = ".update"
    else
      flash.now[:error] = ".update"
      render :edit_step2, status: :unprocessable_entity
    end
  end

  # DELETE /socials/1 or /socials/1.json
  def destroy
    @profile = @social.profile
    @social.destroy!
    set_socials
    flash.now[:success] = ".remove"
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
