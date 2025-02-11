# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :load_and_authorize_profile, except: [:new]
  before_action :load_person, except: %i[set_favorite_picture new]

  # GET /person/:sciper/profile/new
  # Profiles will be saved to DB only if an authorised person click on the edit link
  def new
    @person = Person.find(params[:sciper])
    authorize!(@person, to: :update?)
    @profile = @person.profile!
    @profile.save unless @profile.persisted?
    redirect_to edit_profile_path(@profile)
  end

  def edit
    @sections = Section.order(:position)
    @profile.complete_standard_boxes!

    boxes = @profile.boxes.includes(:section).sort do |a, b|
      [a.section.position, a.position] <=> [b.section.position, b.position]
    end
    @boxes_by_section = boxes.group_by(&:section)
    box_count_by_model = @profile.boxes.group(:model_box_id).count
    @optional_boxes = ModelBox.includes(:section).optional.select do |b|
      (box_count_by_model[b.id] || 0) < b.max_copies
    end.group_by(&:section_id)
  end

  # PATCH/PUT /profile/:id
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        # format.html { redirect_to edit_profile_path(@profile), notice: "Profile was successfully updated." }
        format.turbo_stream do
          flash.now[:success] = "flash.profile.success.update"
          render :update
        end
        # format.json { render :show, status: :ok, location: @profile }
      else
        # format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:error] = "flash.profile.error.update"
          render :update, status: :unprocessable_entity
        end
        # format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /profile/:id/set_favorite_picture/picture_id
  def set_favorite_picture
    @picture = @profile.pictures.find(params[:picture_id])
    respond_to do |format|
      if @profile.update(selected_picture: @picture)
        @pictures = @profile.pictures
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :set_favorite_picture
        end
        format.json { render :show, status: :ok, location: @profile }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          redirect_to :edit
        end
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_and_authorize_profile
    @profile ||= Profile.find(params[:id])
    Rails.logger.debug("======= authorized? #{allowed_to?(:update?, @profile) ? 'yes' : 'no'}")
    authorize! @profile, to: :update?
  end

  def load_person
    load_and_authorize_profile
    @person = Person.find(@profile.sciper)
    @name = @person.name
  end

  def profile_params
    params.require(:profile).permit(
      :nationality_fr, :nationality_en, :nationality_it, :nationality_de,
      :expertise_fr, :expertise_en, :expertise_it, :expertise_de,
      :personal_web_url,
      :en_enabled, :fr_enabled, :it_enabled, :de_enabled,
      :show_phone, :show_nationality, :show_weburl
    )
  end
end
