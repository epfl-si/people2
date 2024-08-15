# frozen_string_literal: true

module Ldap
  class Base
    def self.ldap
      @ldap ||= Net::LDAP.new(
        host: Rails.application.config_for(:ldap).host,
        port: Rails.application.config_for(:ldap).port,
        auth: { method: :anonymous }
      )
    end

    def self.base
      @base ||= Rails.application.config_for(:ldap).base
    end
  end
end
