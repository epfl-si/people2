# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class NamesCacheJob < ApplicationJob
  queue_as :default
  def perform(force: true, cleanup: false)
    all_people = ldap_by_sciper(force: force)
    all_valid_scipers = all_people.keys
    all_known_scipers = Work::Sciper.all.pluck(:sciper)

    scipers_agenda = all_valid_scipers - all_known_scipers
    # puts "agenda: #{scipers_agenda.count}"
    # puts "agenda: #{scipers_agenda.first(10).inspect}"
    # puts "keys: #{all_people.keys.first(10).inspect}"
    new_records = scipers_agenda.map { |s| { email: nil }.merge(all_people[s].to_h) }
    # puts "new_records: #{new_records.first(10).inspect}"
    Work::Sciper.insert_all(new_records)

    return unless cleanup

    scipers_delenda = all_known_scipers - all_valid_scipers
    Work::Sciper.where(sciper: scipers_delenda).delete_all
  end

  def ldap_by_sciper(force: false)
    ldpath = Rails.root.join("tmp/ldap_scipers_emails.txt")
    # TODO: replace with Net::LDAP or install ldapsearch in the container
    if force || !File.exist?(ldpath)
      cmd = "ldapsearch -x -H ldap://ldap.epfl.ch:389 -b 'o=epfl,c=ch'"
      cmd += " '(&(objectClass=person)(!(ou=services))(!(employeeType=Ignore)))'"
      cmd += " uniqueidentifier mail displayName"
      cmd += " | grep -E '^(dn|mail|uniqueIdentifier|displayName):|^$' > #{ldpath}"
      system(cmd)
    end
    mui = /^uniqueIdentifier: ([0-9]+)$/
    mma = /^mail: ([a-z\-.]+@epfl\.ch)$/
    mnn = /^displayName:(:?) (.+)$/

    data = {}
    r = OpenStruct.new
    s = nil
    File.foreach(ldpath).with_index do |l, _nl|
      l.chomp!
      if l.empty? && s.present?
        data[s.to_s] = r if s.present?
        r = OpenStruct.new
        next
      elsif (m = mui.match(l))
        s = r.sciper = m[1]
      elsif (m = mma.match(l))
        r.email = m[1]
      elsif (m = mnn.match(l))
        r.name = m[1].blank? ? m[2] : "NA"
      end
    end
    data
  end
end
# rubocop:enable Rails/SkipsModelValidations
