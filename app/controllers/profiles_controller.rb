# frozen_string_literal: true

class ProfilesController < BackendController
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

  def edit; end

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
      :nationality_fr, :nationality_en,
      :title_fr, :title_en,
      :personal_web_url,
      :show_function, :show_phone, :show_nationality, :show_title, :show_weburl,
      :experiences, experiences_attributes: %i[
        title_en title_fr location
        year_begin year_end audience visible
      ]
    )
  end
end
