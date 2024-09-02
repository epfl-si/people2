# frozen_string_literal: true

class PublicationsController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_publication, only: %i[show edit update destroy toggle]

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
          flash.now[:success] = "Publication was successfully created."
          render :create
        end
        format.html do
          redirect_to profile_publications_path(@profile), notice: 'Publication was successfully created.'
        end
        format.json { render :show, status: :created, location: @publication }
      else
        format.turbo_stream do
          flash.now[:error] = "There was an error creating the publication."
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
          flash.now[:success] = "Publication was successfully updated."
          render :update
        end
        format.html do
          redirect_to profile_publications_path(@profile), notice: 'Publication was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @publication }
      else
        format.turbo_stream do
          flash.now[:error] = "There was an error updating the publication."
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
        flash.now[:success] = "Publication was successfully destroyed."
        render :destroy
      end
      format.html do
        redirect_to profile_publications_path(@profile), notice: 'Publication was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def toggle
    respond_to do |format|
      if @publication.update(visible: !@publication.visible?)
        format.turbo_stream { render :update }
        format.json { render :show, status: :ok, location: @publication }
      else
        format.turbo_stream do
          flash.now[:error] = "There was an error updating the publication visibility."
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_publication
    @publication = Publication.find(params[:id])
  end

  def publication_params
    params.require(:publication).permit(:title, :journal, :year, :authors, :url, :position, :audience, :visible)
  end
end
