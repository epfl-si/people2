# frozen_string_literal: true

class VisibilityController < ApplicationController
  # PATCH/PUT /socials/1 or /socials/1.json
  def update
    klass = params[:model].camelize
    # TODO: restrict allowed values of klass
    @item = Kernel.const_get(klass).find params[:id]
    @item.visibility = params[:visibility]
    respond_to do |format|
      if @item.save
        format.turbo_stream
      else
        format.turbo_stream do
          flash.now[:error] = "flash.generic.error.update"
        end
      end
    end
  end
end
