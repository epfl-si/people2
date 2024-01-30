# frozen_string_literal: true

class IsaService < ApplicationService
  attr_reader :url, :id

  def http_opts
    return {} unless Rails.application.config_for(:epflapi).isa_no_check_ssl

    {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  end
end
