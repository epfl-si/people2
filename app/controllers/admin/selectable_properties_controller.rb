# frozen_string_literal: true

module Admin
  class SelectablePropertiesController < BaseController
    def index
      @selectable_properties = SelectableProperty.order(%i[property label])
    end

    # def show
    #   @selectable_property = SelectableProperty.find(params[:id])
    # end

    def edit
      @selectable_property = SelectableProperty.find(params[:id])
    end

    def update
      @selectable_property = SelectableProperty.find(params[:id])
      if @selectable_property.update(sp_params)
        redirect_to admin_selectable_properties_path
      else
        render action: edit
      end
    end

    private

    def sp_params
      params.require(:selectable_property).permit(
        :name_fr, :name_en, :name_it, :name_de, :default
      )
    end
  end
end
