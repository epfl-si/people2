# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :register_client_origin

  def devindex; end

  def self.unique_counter_value
    @indx ||= 0
    @indx += 1
    @indx
  end

  def default_url_options
    { lang: I18n.locale }
  end

  def compute_audience(sciper)
    @audience = if user_signed_in?
                  if current_user.sciper == sciper
                    3
                  else
                    2
                  end
                elsif @is_intranet_client
                  1
                else
                  0
                end
    return unless Rails.env.development?

    fe = ENV.fetch('FORCE_AUDIENCE', false)
    return unless fe

    @original_audience = @audience
    @audience = [[0, fe.to_i].max, 3].min
  end

  private

  def switch_locale(&action)
    locale = params[:lang] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def register_client_origin
    @is_intranet_client = Rails.configuration.intranet_re.match?(request.remote_ip)
  end
end
