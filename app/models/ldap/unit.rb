# frozen_string_literal: true

module Ldap
  class Unit < Base
    attr_reader :dn, :cn, :ou, :oulong

    def self.find(b)
      o = {
        base: b,
        scope: Net::LDAP::SearchScope_BaseObject,
        attributes: ["dn", "cn", "ou;lang-en", "unitManager", "ou"],
        filter: Net::LDAP::Filter.eq(:objectClass, "EPFLorganizationalUnit")
      }
      l = Base.ldap.search(o)
      l.present? ? new(l.first) : nil
    end

    def initialize(d)
      @dn = d.dn
      @cn = d.cn.first
      @oulong = d["ou;lang-en"].first
      @ou = d.ou.min { |a, b| a.length <=> b.length }
      @msciper = d.unitManager.first
    end

    def members
      @members ||= Base.ldap.search(
        base: @dn,
        scope: Net::LDAP::SearchScope_SingleLevel,
        attributes: ["dn"],
        filter: Net::LDAP::Filter.eq(:objectClass, "person") &
                Net::LDAP::Filter.ne(:employeeType, "Ignore")
      ).map { |r| Person.for_dn(r.dn) }.compact.sort { |a, b| a.name <=> b.name }
    end

    def all_members
      @all_members ||= Base.ldap.search(
        base: @dn,
        attributes: ["dn"],
        filter: Net::LDAP::Filter.eq(:objectClass, "person") &
                Net::LDAP::Filter.ne(:userClass, "Stagiaire") &
                Net::LDAP::Filter.ne(:employeeType, "Ignore") &
                Net::LDAP::Filter.ne(:description, "Consultant") &
                Net::LDAP::Filter.ne(:organizationalstatus, "Hors EPFL") &
                Net::LDAP::Filter.ne(:organizationalstatus, "Hôte")
      ).map { |r| Person.for_dn(r.dn) }.compact.sort { |a, b| a.name <=> b.name }.uniq(&:sciper)
    end

    def manager
      @manager ||= Person.for_sciper(@msciper)
    end

    def to_s
      a = "#{@dn}: #{@ou} (#{@oulong}) <- #{manager.name}\n"
      members.each { |m| a << "                      #{m}\n" }
      a
    end
  end
end
