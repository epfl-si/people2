# frozen_string_literal: true

class VisibilityController < ApplicationController
  # PATCH/PUT /visibility/accred/1
  def update
    # klass = params[:model].camelize
    # # TODO: restrict allowed values of klass
    # @item = Kernel.const_get(klass).find params[:id]
    m = params[:model]
    klass = m.classify.constantize
    @item = klass.find params[:id]
    authorize! @item, to: :update?
    if (@property = params[:property]).present?
      @item.send("#{@property}_visibility=", params[:visibility])
    else
      @item.visibility = params[:visibility]
    end

    respond_to do |format|
      if @item.save
        format.turbo_stream do
          flash.now[:success] = if @property.present?
                                  I18n.t(
                                    "flash.visibilities.update.property.success",
                                    item: I18n.t("activerecord.models.#{m}"),
                                    attr: I18n.t("activerecord.attributes.#{m}.#{@property}")
                                  )
                                else
                                  I18n.t(
                                    "flash.visibilities.update.record.success",
                                    item: I18n.t("activerecord.models.#{m}")
                                  )
                                end
        end
      else
        format.turbo_stream do
          flash.now[:error] =
            if @item.errors.present?
              @item.errors.map(&:message)
            else
              ".update"
            end
          # Revert model to previous state ???
          # @item = klass.find params[:id]
        end
      end
    end
  end
end
