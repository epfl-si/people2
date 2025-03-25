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

    # Methods that are not explicitly defined are assumed to be keys of @data
    # Fields that are expected to be always present will except if not found
    def method_missing(key, *_args)
      res = @data[key]
      return res unless res.is_a?(Array)

      if res.empty?
        nil
      elsif res.count == 1
        res.first
      else
        res
      end
    end

    def respond_to_missing?(key, include_private = false)
      @data.attribute_names.include?(key) || super
    end
  end
end
