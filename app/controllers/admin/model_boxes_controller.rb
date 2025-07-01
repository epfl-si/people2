# frozen_string_literal: true

module Admin
  class ModelBoxesController < BaseController
    def index
      @boxes = ModelBox.all
    end

    def show
      @box = ModelBox.find(params[:id])
    end

    def edit
      @box = ModelBox.find(params[:id])
    end

    def update
      @box = ModelBox.find(params[:id])
      if @box.update(model_box_params)
        redirect_to [:admin, @box]
      else
        render action: :edit
      end
    end

    private

    def model_box_params
      params.require(:model_box).permit(
        :title_fr, :title_en, :title_it, :title_de,
        :help_en, :help_fr, :help_it, :help_de,
        :description_fr, :description_en, :description_it, :description_de,
        :standard, :show_title, :locked_title,
        :section, :max_copies
      )
    end
  end
end
