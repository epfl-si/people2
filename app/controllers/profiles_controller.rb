# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :require_recent_authentication
  before_action :load_and_authorize_profile_and_person, except: %i[new]

  # GET /people/:sciper/profile/new
  # Profiles will be saved to DB only if an authorised person click on the edit link
  def new
    @person ||= Person.find(params[:sciper_or_name])
    authorize! @person, to: :update?

    @profile = @person.profile!
    @profile.save unless @profile.persisted?
    redirect_to edit_profile_path(@profile)
  end

  def edit
    if params[:details]
      render 'edit_details'
    elsif params[:official_name]
      render 'profiles/name_change/official'
    elsif params[:usual_name]
      authorize!(@person, to: :confidential_edit?)
      load_confidential_person(@profile.sciper)
      render 'profiles/name_change/usual'
    elsif params[:languages]
      render 'edit_languages'
    else
      load_confidential_person(@profile.sciper) if allowed_to?(:confidential_edit?, @person)
      force_profile_locale(@profile)
      # TODO: remove after migration from legacy
      @adoption = Adoption.where(sciper: @profile.sciper).first if Rails.configuration.enable_adoption

      @contact_sections = Section.where(edit_zone: "contact")
      @sections = Section.where.not(edit_zone: "contact").order(:position)
      @profile.complete_standard_boxes!

      boxes = @profile.boxes.includes(:section, :model).sort do |a, b|
        [a.section.position, a.position] <=> [b.section.position, b.position]
      end
      @boxes_by_section = boxes.group_by(&:section)
      box_count_by_model = @profile.boxes.group(:model_box_id).count
      @optional_boxes = ModelBox.includes(:section).optional.select do |b|
        (box_count_by_model[b.id] || 0) < b.max_copies
      end.group_by(&:section_id)
    end
  end

  # PATCH/PUT /profile/:id
  def update
    part = params[:part]
    case part
    when "languages"
      update_languages
    when "inclusivity"
      authorize!(@profile, to: :confidential_edit?)
      update_inclusivity
    when "name"
      raise NotImplementedError
    else
      update_base
    end
  end

  FIELD_TO_TURBO_FRAME = {
    "nationality" => "profile_field_nationality",
    "expertise" => "profile_field_expertise",
    "personal_web_url" => "profile_field_personal_web_url",
    "personal_phone" => "profile_field_personal_phone"
  }.freeze

  def update_base
    focus_field = params[:focus_field] || params[:part]
    frame_id = FIELD_TO_TURBO_FRAME[focus_field]

    respond_to do |format|
      if @profile.update(profile_params)
        # Success
        format.turbo_stream do
          turbo_flash(:success, label: "#{focus_field}_success")
          render turbo_stream: [
            turbo_stream.update(
              frame_id,
              partial: "profiles/fields/field_#{focus_field}",
              locals: { profile: @profile }
            ),
            turbo_stream.replace("flash-messages", partial: "shared/flash")
          ]
        end
      else
        # Validation error
        format.turbo_stream do
          turbo_flash(:error, label: "#{focus_field}_error")
          render turbo_stream: [
            turbo_stream.update(
              frame_id,
              partial: "profiles/fields/field_error",
              locals: { profile: @profile, focus_field: focus_field }
            ),
            turbo_stream.replace("flash-messages", partial: "shared/flash")
          ], status: :unprocessable_entity
        end
      end
    end
  end

  def reset_field
    focus_field = params[:focus_field]
    frame_id = FIELD_TO_TURBO_FRAME[focus_field]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          frame_id,
          partial: "profiles/fields/field_#{focus_field}",
          locals: { profile: @profile }
        )
      end

      # fallback
      format.html { redirect_to edit_profile_path(@profile) }
    end
  end

  # When profile's available languages are changed, we should
  #  1. re-render the language change nav
  #  2. re-render all the partials where the list of profile languages is used
  # Therefore, it is much easier to just reload everything e buona notte
  def update_languages
    if @profile.update(profile_params)
      base_flash(:success, label: "languages_success")
    else
      base_flash(:error, label: "languages_error")
    end
    redirect_to edit_profile_path(@profile)
  end
  #     Rails.logger.debug("part=#{part}")
  #     if @profile.update(profile_params)
  #       if part && part == "languages"
  #         Rails.logger.debug("part is languages => redirecting")
  #       end
  #       # format.html { redirect_to edit_profile_path(@profile), notice: "Profile was successfully updated." }
  #       format.turbo_stream do
  #         flash.now[:success] = "flash.profile.success.update"
  #         render :update
  #       end
  #       # format.json { render :show, status: :ok, location: @profile }
  #     else
  #     end
  #   end
  # end

  def update_inclusivity
    if @profile.update(profile_params)
      turbo_flash(:success, label: "inclusivity_success")
      new_gender = @profile.inclusivity ? "X" : @person.genderofficial
      ProfilePatchJob.perform_later(sciper: @profile.sciper, gender: new_gender)
      respond_to do |format|
        format.turbo_stream { render "inclusivity/update" }
      end
    else
      turbo_flash(:error, label: "inclusivity_error")
      render :inclusivity_section, status: :unprocessable_entity
    end
  end

  # PATCH /profile/:id/set_favorite_picture/picture_id
  def set_favorite_picture
    @picture = @profile.pictures.find(params[:picture_id])
    respond_to do |format|
      if @profile.update(selected_picture: @picture)
        @pictures = @profile.pictures
        format.turbo_stream do
          turbo_flash(:success)
          render :set_favorite_picture
        end
        format.json { render :show, status: :ok, location: @profile }
      else
        format.turbo_stream do
          turbo_flash(:error)
          redirect_to :edit
        end
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def request_default_locale
    @profile&.translations&.first
  end

  private

  def load_and_authorize_profile_and_person
    @profile = Profile.find(params[:id])
    authorize! @profile, to: :update?

    if allowed_to?(:confidential_edit?, @profile)
      load_confidential_person(@profile.sciper)
    else
      @person = Person.find_by_sciper(@profile.sciper, force: true)
    end
  end

  def load_confidential_person(sciper)
    jwt = Current.session.jwt
    return if jwt.blank?

    begin
      @person = Person.find_by_sciper(sciper, force: true, auth: jwt)
    rescue ActiveRecord::RecordNotFound
      # JWT token probably expired. We need to force authentication.
      Rails.logger.debug "Person request to api failed. Trying to force authentication"
      require_recent_authentication
    end
    @profile.person = @person if @profile.present?
  end

  def profile_params
    params.require(:profile).permit(
      :inclusivity,
      :t_nationality, :t_expertise, :personal_web_url, :personal_phone,
      :nationality_fr, :nationality_en, :nationality_it, :nationality_de,
      :expertise_fr, :expertise_en, :expertise_it, :expertise_de,
      :personal_web_url, :personal_phone,
      :en_enabled, :fr_enabled, :it_enabled, :de_enabled,
      :personal_phone_visibility, :personal_web_url_visibility,
      :nationality_visibility, :expertise_visibility, :photo_visibility
    )
  end
end
