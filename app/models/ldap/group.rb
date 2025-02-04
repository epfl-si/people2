# frozen_string_literal: true

module Ldap
  class Group < Base
    attr_reader :dn, :cn, :id, :gid

    def self.find_by_name(name)
      o = {
        base: "ou=groups,#{Base.base}",
        filter: Net::LDAP::Filter.eq(:objectClass, "groupOfNames") &
                Net::LDAP::Filter.eq(:cn, name)
      }
      l = Base.ldap.search(o)
      l.present? ? new(l.first) : nil
    end

    def initialize(d)
      @dn = d.dn
      @cn = d.cn.first
      @gid = d.gidNumber.first
      @id  = d.uniqueIdentifier.first
    end

    def to_s
      "#{@dn}: #{@cn} / #{@gid} / #{@id}"
    end
  end
end
