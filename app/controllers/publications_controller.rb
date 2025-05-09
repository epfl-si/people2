# frozen_string_literal: true

class PublicationsController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_publication, only: %i[show edit update destroy]

  def index
    @publications = @profile.publications.order(:position)
  end

  def show; end

  def new
    @publication = Publication.new
  end

  def edit; end

  def create
    @publication = @profile.publications.new(publication_params)

    respond_to do |format|
      if @publication.save
        format.turbo_stream do
          flash.now[:success] = ".create"
          render :create
        end
        format.html do
          redirect_to profile_publications_path(@profile), notice: 'Publication was successfully created.'
        end
        format.json { render :show, status: :created, location: @publication }
      else
        format.turbo_stream do
          flash.now[:error] = ".create"
          render :new, status: :unprocessable_entity
        end
        format.html { render :new }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.turbo_stream do
          flash.now[:success] = ".update"
          render :update
        end
        format.html do
          redirect_to profile_publications_path(@profile), notice: '.update'
        end
        format.json { render :show, status: :ok, location: @publication }
      else
        format.turbo_stream do
          flash.now[:error] = ".update"
          render :edit, status: :unprocessable_entity
        end
        format.html { render :edit }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @publication.destroy!
    respond_to do |format|
      format.turbo_stream do
        flash.now[:success] = ".remove"
        render :destroy
      end
      format.html do
        redirect_to profile_publications_path(@profile), notice: '.remove'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_publication
    @publication = Publication.includes(:profile).find(params[:id])
  end

  def publication_params
    params.require(:publication).permit(:title, :journal, :year, :authors, :url, :position, :visibility)
  end
end
