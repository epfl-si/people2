# frozen_string_literal: true

# Taken from https://dev.to/mjc/automatic-rails-flash-messages-with-localization-support-4cbl
module Flashable
  extend ActiveSupport::Concern

  # Keep it as an on-demand feature
  # included do
  #   after_action :auto_flash_for_html
  # end

  def auto_flash_for_html
    return unless request.format.html?
    return unless request.post? || request.patch? || request.delete?

    case response.status
    when 200..399
      base_flash(:success)
    when 400..499
      base_flash(:error)
    end
  end

  # TODO: the generic message might take the model name inferred from the controller name
  def t_flash_message(default_label, **opts)
    l = opts[:label] || default_label
    r = opts[:record] || controller_name.classify
    tr = I18n.t(:"activerecord.models.#{r.underscore}", default: r.humanize)
    opts[:record] || I18n.t("activerecord.models.#{controller_name.classify.underscore}")
    a = :"flash.#{controller_name}.#{action_name}.#{l}"
    b = :"flash.generic.#{action_name}.#{default_label}"
    c = :"flash.generic.#{default_label}"
    I18n.t(a, default: I18n.t(b, record: tr, default: I18n.t(c)))
    # defaults = [
    #   :"flash.generic.#{action_name}.#{default_label}",
    #   :"flash.generic.#{default_label}"
    # ]
    # I18n.t(a, defaults: defaults)
  end

  def base_flash(status, **opts)
    case status
    when :success
      flash[:notice] = t_flash_message('success', **opts)
    when :error
      flash[:alert] = t_flash_message('error', **opts)
    end
  end

  # There must be a way to do an equivalent thing for turbo stream but it is more
  # difficult because it involves rendering the flash partiaal before knowing the
  # response.status. Therefore, for the moment I just call this helper manually
  # and have to turbo_stream.replace("flash-messages", partial: "shared/flash")
  # while rendering
  def turbo_flash(status, **opts)
    case status
    when :success
      flash.now[:notice] = t_flash_message('success', **opts)
    when :error
      flash.now[:alert] = t_flash_message('error', **opts)
    end
  end

  def turbo_flash_render(status, **opts)
    turbo_flash(status, **opts)
    turbo_stream.replace("flash-messages", partial: "shared/flash")
  end
end
