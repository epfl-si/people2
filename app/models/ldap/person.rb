# frozen_string_literal: true

module Ldap
  class Person < Base
    attr_reader :name, :sciper, :email, :data, :type

    def self.for_dn(dn)
      find(
        base: dn,
        scope: Net::LDAP::SearchScope_BaseObject
      )
    end

    def self.for_sciper(sciper)
      find(
        filter: Net::LDAP::Filter.eq(:uniqueIdentifier, sciper)
      )
    end

    def self.find(opts = {})
      o = {
        base: Base.base,
        filter: Net::LDAP::Filter.eq(:objectClass, "person")
      }.merge(opts)
      l = Base.ldap.search(o)
      return if l.blank?

      new(l.first)
    end

    def initialize(d)
      @data = d
      begin
        @email = @data.mail.first
      rescue StandardError
        @email = "unknown@epfl.ch"
      end
      @name = @data.displayName.first
      @sciper = @data.uniqueidentifier.first
      begin
        @type = @data.employeeType.first
      rescue StandardError
        @type = "unknown"
      end
    end

    def to_s
      "#{@sciper} - #{@name}"
    end
  end
end
