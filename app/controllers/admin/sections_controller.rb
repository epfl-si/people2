# frozen_string_literal: true

module Admin
  class SectionsController < ApplicationController
    def index
      @sections = Section.all
    end

    def show
      @section = Section.find(params[:id])
    end

    def edit
      @section = Section.find(params[:id])
    end

    def update
      @section = Section.find(params[:id])
      if @section.update(section_params)
        redirect_to [:admin, @section]
      else
        render action: :edit
      end
    end

    private

    def section_params
      params.require(:section).permit(
        :title_fr, :title_en, :title_it, :title_de,
        :help_en, :help_fr, :help_it, :help_de,
        :zone, :edit_zone, :label,
        :show_title, :create_allowed
      )
    end
  end
end
