# frozen_string_literal: true

module Admin
  module Sections
    class ModelBoxesController < BaseController
      def index
        @section = Section.find(params[:section_id])
        @boxes = @section.model_boxes.order(:position)
      end

      # def edit
      #   @box = ModelBox.find(params[:id])
      # end

      def update
        @box = ModelBox.find(params[:id])
        if @box.update(model_box_params)
          render json: @box
        else
          render json: @box, status: :unprocessable_entity
        end
      end

      private

      def model_box_params
        params.require(:model_box).permit(:position)
      end
    end
  end
end
