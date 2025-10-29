# frozen_string_literal: true

class VisibilityController < ApplicationController
  # PATCH/PUT /visibility/accred/1
  def update
    m = params[:model]
    raise ActionController::BadRequest, "Invalid model" unless SafeReflection.allowed?(m)

    klass = SafeReflection.class_for(m)

    # klass = m.classify.constantize
    @item = klass.find params[:id]
    authorize! @item, to: :update?
    if (@property = params[:property]).present?
      prop_visibility = @item.safe_visibility_for(@property)
      raise ActionController::BadRequest if prop_visibility.nil?

      old_visibility = @item.send(prop_visibility)
      @item.send("#{prop_visibility}=", params[:visibility])
    else
      raise ActionController::BadRequest unless @item.audience_limitable?

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
          @item.send("#{prop_visibility}=", old_visibility)
        else
          @item.visibility = old_visibility
        end
      end
    end
  end
end
