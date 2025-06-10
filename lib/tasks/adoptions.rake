# frozen_string_literal: true

require 'net/http'
require 'base64'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :legacy do
  desc 'Check which scipers are still valid and eligible to have a people account'
  task adoptions: :environment do
    ldpath = Rails.root.join("tmp/ldap_scipers_emails.txt")
    # TODO: replace with Net::LDAP or install ldapsearch in the container
    unless File.exist?(ldpath)
      cmd = "ldapsearch -x -H ldap://ldap.epfl.ch:389 -b 'o=epfl,c=ch'"
      cmd += " '(&(objectClass=person)(!(ou=services)))'"
      cmd += " uniqueidentifier mail displayName"
      cmd += " | grep -E '^(dn|mail|uniqueIdentifier|displayName):|^$' > #{ldpath}"
      system(cmd)
    end

    had_profile = Legacy::Cv.all.pluck(:sciper).uniq.index_with { |_k| true }
    scipers_todo = (
      Work::Sciper.migranda.pluck(:sciper) - Adoption.all.pluck(:sciper)
    ).uniq.index_with { |_k| true }
    puts "Adoption count before: #{Adoption.count}"

    mui = /^uniqueIdentifier: ([0-9]+)$/
    mma = /^mail: ([a-z.]+@epfl\.ch)$/
    mnn = /^displayName:(:?) (.+)$/
    mdn = /^dn: (.+)$/

    data = []
    r = {}
    s = n = nil
    File.foreach(ldpath).with_index do |l, _nl|
      l.chomp!
      if l.empty?
        if s.present? && scipers_todo.key?(s)
          had_profile.key?(s)
          data << { accepted: false, email: nil, fullname: nil }.merge(r)
        end
        r = {}
        next
      elsif (m = mui.match(l))
        s = r[:sciper] = m[1]
      elsif (m = mma.match(l))
        n = r[:email] = m[1]
      elsif (m = mnn.match(l))
        r[:fullname] = m[1].blank? ? m[2] : Base64.decode64(m[2]).force_encoding("UTF-8")
      elsif (m = mdn.match(l))
        r[:dn] = m[1]
      end
    end
    # rubocop:disable Rails/SkipsModelValidations
    # because there are no validations in Adoption and data is ok by construction
    Adoption.insert_all(data.select { |v| scipers_todo[v[:sciper]] })
    # rubocop:enable Rails/SkipsModelValidations
    puts "Adoption count after:  #{Adoption.count}"
  end
end
