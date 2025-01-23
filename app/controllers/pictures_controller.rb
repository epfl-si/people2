# frozen_string_literal: true

class PicturesController < BackendController
  before_action :set_picture, only: %i[crop update destroy]
  before_action :set_profile, only: %i[crop update]

  # GET /profile/profile_id/pictures or /profile/profile_id/pictures.json
  def index
    @profile = Profile.find(params[:profile_id])
    @pictures = Picture.order(:camipro)
  end

  # # GET /pictures/1 or /pictures/1.json
  # def show; end

  # # GET /pictures/1/edit
  # def edit; end

  # for an alternative solution, have a look to
  # https://medium.com/@fabriciobonjorno/upload-profile-image-in-real-time-1c74313a1116
  # POST /profile/profile_id/pictures or /profile/profile_id/pictures.json

  def crop
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "profile_picture",
          partial: "pictures/crop",
          locals: { picture: @picture }
        )
      end
    end
  end

  def update
    unless params[:picture].present? && params[:picture][:cropped_image].present?
      render json: { error: "No cropped image data provided" }, status: :unprocessable_entity and return
    end

    begin
      file = data_url_to_uploaded_file(params[:picture][:cropped_image])
      @picture.cropped_image.attach(file)
    rescue StandardError
      flash.now[:error] = "flash.generic.error.update"
      render json: { error: "Unable to process cropped image" }, status: :unprocessable_entity and return
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = "flash.generic.success.update"
        render :update
      end
      format.html { redirect_to picture_path(@picture), notice: "Picture updated successfully." }
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

  def data_url_to_uploaded_file(data_url)
    content_type = data_url[/data:(.*?);base64,/, 1]
    decoded_data = Base64.decode64(data_url.split(",")[1])
    filename = "cropped_image.#{content_type.split('/').last}"

    tempfile = Tempfile.new(filename)
    tempfile.binmode
    tempfile.write(decoded_data)
    tempfile.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end
end
