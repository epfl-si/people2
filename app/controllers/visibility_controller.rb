# frozen_string_literal: true

class VisibilityController < ApplicationController
  # PATCH/PUT /visibility/accred/1
  def update
    klass = params[:model].camelize
    # TODO: restrict allowed values of klass
    @item = Kernel.const_get(klass).find params[:id]
    if (@property = params[:property]).present?
      @item.send("#{@property}_visibility=", params[:visibility])
    else
      @item.visibility = params[:visibility]
    end
    respond_to do |format|
      if @item.save
        format.turbo_stream
        flash.now[:success] = "flash.generic.success.update"
      else
        format.turbo_stream do
          flash.now[:error] =
            if @item.errors.present?
              @item.errors.map(&:full_message).join(",")
            else
              "flash.generic.error.update"
            end
          # Revert model to previous state
          @item = Kernel.const_get(klass).find params[:id]
        end
      end
    end
  end
end
