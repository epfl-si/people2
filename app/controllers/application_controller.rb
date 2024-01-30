# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :register_client_origin

  # INTRANET_RE = Regexp.new(ENV.fetch("INTRANET_RE", '^128\.17[89]'))

  def homepage; end

  def self.unique_counter_value
    @indx ||= 0
    @indx += 1
    @indx
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
