# frozen_string_literal: true

module Help
  class HelpsController < ApplicationController
    def show; end

    def box
      box = Box.find(params[:id])
      @title = box.model.t_title(I18n.locale)
      @help = box.model.t_help(I18n.locale)
      render 'show'
    end

    def section
      section = Section.find(params[:id])
      @title = section.t_title(I18n.locale)
      @help = section.t_help(I18n.locale)
      render 'show'
    end

    def ui
      label = params[:label]
      @title = t("help.title.#{label}")
      @help  = t("help.content.#{label}_html")
      render 'show'
    end
  end
end
