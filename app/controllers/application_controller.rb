# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :register_client_origin

  include Authentication

  def self.unique_counter_value
    @indx ||= 0
    @indx += 1
    @indx
  end

  def default_url_options
    { lang: I18n.locale }
  end

  def compute_audience(sciper)
    @audience = if authenticated?
                  if Current.user.sciper == sciper
                    AudienceLimitable::OWNER
                  else
                    AudienceLimitable::AUTENTICATED
                  end
                elsif @is_intranet_client
                  AudienceLimitable::INTRANET
                else
                  AudienceLimitable::WORLD
                end
    return unless (fe = Rails.configuration.force_audience)

    @original_audience = @audience
    @audience = [[AudienceLimitable::WORLD, fe.to_i].max, AudienceLimitable::OWNER].min
  end

  private

  # This is for situation that should not arrive. In case, we want to provide
  # meaningful output in all formats.
  def unexpected(message)
    respond_to do |format|
      format.html do
        render inline: "<p><%= message %></p>", status: :forbidden
      end
      format.turbo_stream do
        flash.now[:error] = message
        render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash")
      end
      format.json { render json: { msg: message }, status: :forbidden }
    end
  end

  # TODO: this is intended for larger notifications than just the flash.
  #       We have to implement a larger dismissable popup box or recycle the
  #       one for editing or an identical one with dismiss button by default.
  def notifier(message)
    respond_to do |format|
      format.html do
        render inline: "<p><%= message %></p>"
      end
      format.turbo_stream do
        flash.now[:info] = message
        render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash")
      end
      format.json { render json: { msg: message } }
    end
  end

  def switch_locale(&action)
    locale = params[:lang] || I18n.default_locale
    Current.primary_lang = locale
    Current.fallback_lang = I18n.default_locale
    Current.gender = nil
    I18n.with_locale(locale, &action)
  end

  # TODO: This is not the correct way of finding internal clients. The reliable
  # way is to check if X-EPFL-Internal header is set in the request.
  def register_client_origin
    @is_intranet_client = Rails.configuration.intranet_re.match?(request.remote_ip)
  end

  def current_user
    Current.user
  end
end
