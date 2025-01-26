# frozen_string_literal: true

class PicturesController < BackendController
  before_action :set_picture, only: %i[edit update destroy]
  before_action :set_profile, only: %i[edit update]

  # GET /profile/profile_id/pictures or /profile/profile_id/pictures.json
  def index
    @profile = Profile.find(params[:profile_id])
    @pictures = @profile.pictures
  end

  # # GET /pictures/1 or /pictures/1.json
  # def show; end

  # # GET /pictures/1/edit
  # def edit; end

  # for an alternative solution, have a look to
  # https://medium.com/@fabriciobonjorno/upload-profile-image-in-real-time-1c74313a1116
  # POST /profile/profile_id/pictures or /profile/profile_id/pictures.json

  # # GET /pictures/1/edit
  def edit; end

  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.update"
          render :update
        end
        format.json { render :show, status: :ok, location: @picture }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
          render :edit, status: :unprocessable_entity, locals: { profile: @profile, award: @picture }
        end
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    raise "Cannot delete selected photo" if @picture.selected?

    respond_to do |format|
      if @picture.destroy
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.remove"
          render :destroy
        end
        format.json { head :no_content }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.remove"
          render 'shared/flash'
        end
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @profile = Profile.find(params[:profile_id])

    if @profile.pictures.count + 1 > Rails.application.config_for(:limits).max_profile_pictures
      raise "Max number of profile pictures reached"
    end

    @picture = @profile.pictures.new(picture_params)
    respond_to do |format|
      if @picture.save
        format.turbo_stream do
          flash.now[:success] = "flash.generic.success.create"
          render :create, locals: { profile: @profile, picture: @picture }
        end
        format.json { render :show, status: :created, location: @picture }
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.create"
          render :new, status: :unprocessable_entity, locals: { profile: @profile, picture: @picture }
        end
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_profile
    @profile = @picture.profile
  end

  def set_picture
    @picture = Picture.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Picture not found" }, status: :not_found
  end

  def picture_params
    params.require(:picture).permit(:cropped_image, :image)
  end
end
