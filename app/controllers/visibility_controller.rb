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
      old_visibility = @item.send("#{@property}_visibility")
      @item.send("#{@property}_visibility=", params[:visibility])
    else
      old_visibility = @item.visibility
      @item.visibility = params[:visibility]
    end

    respond_to do |format|
      opts = { item: I18n.t("activerecord.models.#{m}") }
      opts[:attr] = I18n.t("activerecord.attributes.#{m}.#{@property}") if @property.present?
      tkey = "flash.visibilities.update.#{@property.present? ? 'property' : 'record'}"
      if @item.save
        format.turbo_stream do
          turbo_flash(:success, tmessage: I18n.t("#{tkey}.success", **opts))
        end
      else
        format.turbo_stream do
          if @item.errors.present?
            turbo_flash(:error, tmessage: @item.errors.map { |e| I18n.t(e.message) }.join(", "))
          else
            turbo_flash(:error, tmessage: I18n.t("#{tkey}.error", **opts))
          end
        end
        # Revert model to previous state
        if @property.present?
          @item.send("#{@property}_visibility=", old_visibility)
        else
          @item.visibility = old_visibility
        end
      end
    end
  end
end
