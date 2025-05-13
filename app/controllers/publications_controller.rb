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
    if @publication.save
      flash.now[:success] = ".create"
    else
      flash.now[:error] = ".create"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @publication.update(publication_params)
      flash.now[:success] = ".update"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @publication.destroy!
    flash.now[:success] = ".remove"
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
