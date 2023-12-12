class IsaService < ApplicationService
  attr_reader :url, :id
  def http_opts
    if Rails.application.config_for(:epflapi).isa_no_check_ssl
      opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
    end
  end
end