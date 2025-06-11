# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

def ldap_by_sciper
  ldpath = Rails.root.join("tmp/ldap_scipers_emails.txt")
  # TODO: replace with Net::LDAP or install ldapsearch in the container
  unless File.exist?(ldpath)
    cmd = "ldapsearch -x -H ldap://ldap.epfl.ch:389 -b 'o=epfl,c=ch'"
    cmd += " '(&(objectClass=person)(!(ou=services)))'"
    cmd += " uniqueidentifier mail displayName"
    cmd += " | grep -E '^(dn|mail|uniqueIdentifier|displayName):|^$' > #{ldpath}"
    system(cmd)
  end
  mui = /^uniqueIdentifier: ([0-9]+)$/
  mma = /^mail: ([a-z\-.]+@epfl\.ch)$/
  mnn = /^displayName:(:?) (.+)$/
  mdn = /^dn: (.+)$/

  data = {}
  r = OpenStruct.new
  s = nil
  File.foreach(ldpath).with_index do |l, _nl|
    l.chomp!
    if l.empty? && s.present?
      data[s.to_i] = r if s.present?
      r = OpenStruct.new
      next
    elsif (m = mui.match(l))
      s = r.sciper = m[1]
    elsif (m = mma.match(l))
      r.email = m[1]
    elsif (m = mnn.match(l))
      r.fullname = m[1].blank? ? m[2] : Base64.decode64(m[2]).force_encoding("UTF-8")
    elsif (m = mdn.match(l))
      r.dn = m[1]
    end
  end
  data
end

namespace :legacy do
  desc 'Reload the scipers table with fresh data'
  task reload_scipers: %i[nuke_scipers scipers] do
  end

  desc 'Nuke scipers from Work::Sciper table'
  task nuke_scipers: :environment do
    Work::Sciper.in_batches(of: 1000).delete_all
  end

  desc 'Update the Scipers table with currently valid scipers'
  task scipers: :environment do
    all_people = ldap_by_sciper

    # all the officially existing scipers
    all_scipers = all_people.keys

    # all the scipers in the DB
    scipers_in_db = Work::Sciper.all.pluck(:sciper)

    scipers_todo = all_scipers - scipers_in_db

    # scipers that currently have a legacy profile
    legacy_scipers = Legacy::Cv.connection.select_all("
      SELECT DISTINCT sciper FROM common
      UNION
      SELECT DISTINCT sciper FROM cv
      UNION
      SELECT DISTINCT sciper FROM accreds
    ").to_a.map { |v| v["sciper"].to_i }.uniq.intersection(scipers_todo)

    # all scipers eligible to have a profile
    profilable_scipers = APIAuthGetter.call(
      authid: "botweb",
      status: "active",
      type: "property",
      force: true # we want to seed with freshest possible data
    ).map { |a| a["persid"].to_i }.uniq.intersection(scipers_todo)

    # those that are not in legacy are considered as already migrated
    migrated = (profilable_scipers - legacy_scipers).map do |s|
      r = all_people[s]
      {
        sciper: s,
        status: Work::Sciper::STATUS_MIGRATED,
        email: r.email,
        name: r.fullname,
      }
    end

    # those that do have a legacy profile will have to be migrated
    migranda = (profilable_scipers.intersection legacy_scipers).map do |s|
      r = all_people[s]
      {
        sciper: s,
        status: Work::Sciper::STATUS_WITH_LEGACY_PROFILE,
        email: r.email,
        name: r.fullname,
      }
    end

    noprofile = (scipers_todo - profilable_scipers).map do |s|
      r = all_people[s]
      {
        sciper: s,
        status: Work::Sciper::STATUS_NO_PROFILE,
        email: r.email,
        name: r.fullname,
      }
    end

    puts "No. total valid scipers:           #{all_scipers.count}"
    puts "No. total scipers already in DB:   #{scipers_in_db.count}"
    puts "No. unique scipers in legacy db:   #{legacy_scipers.count}"
    puts "No. unique eligible scipers:       #{profilable_scipers.count}"
    puts "No. migranda to add:               #{migranda.count}"
    puts "No. migrated to add:               #{migrated.count}"
    puts "No. no profile to add:             #{noprofile.count}"

    # rubocop:disable Rails/SkipsModelValidations
    Work::Sciper.insert_all(migranda)
    Work::Sciper.insert_all(migrated)
    Work::Sciper.insert_all(noprofile)
    # rubocop:enable Rails/SkipsModelValidations
  end

  desc 'Dump text boxes to check sanitizer effectiveness'
  task dump_text_boxes: :environment do
    oks = Work::Sciper.where(status: 3).map(&:sciper)
    bb = Legacy::Box.with_content.free_text.where(sciper: oks)
    File.open(Rails.root.join("tmp/freetext_boxes.txt"), 'w+') do |f|
      bb.each do |b|
        f.puts "=============================================== #{b.id} #{b.sciper}"
        f.puts b.content
        f.puts "----------------------------------------------- #{b.id}"
        f.puts
      end
    end

    File.open(Rails.root.join("tmp/freetext_boxes_sanitized.txt"), 'w+') do |f|
      bb.each do |b|
        f.puts "=============================================== #{b.id} #{b.sciper}"
        f.puts b.sanitized_content
        f.puts "----------------------------------------------- #{b.id}"
        f.puts
      end
    end
  end

  desc 'Legacy profile language and effective editing'
  task editing_stats: :environment do
    n_persons = Work::Sciper.live.count
    n_profile_enabled = Work::Sciper.with_profile.count

    scipers = Work::Sciper.with_profile.map(&:sciper)
    scipers_en = Legacy::Cv.select('sciper').where(sciper: scipers, defaultcv: "en").map(&:sciper)
    scipers_fr = Legacy::Cv.select('sciper').where(sciper: scipers, defaultcv: "fr").map(&:sciper)
    scipers_ml = scipers - scipers_en - scipers_fr

    n_profiles = Legacy::Cv.where(sciper: scipers).count
    n_profiles_en = scipers_en.count
    n_profiles_fr = scipers_fr.count
    n_profiles_ml = scipers_ml.count

    fmt1 = "%60s: %6d\n"
    fmt2 = "%60s: %6d -> %6d distinct profiles\n"

    printf("\n----------------- Number of\n")
    printf(fmt1, "persons", n_persons)
    printf(fmt1, "persons that can have a profile", n_profile_enabled)
    printf(fmt1, "profiles in people", n_profiles)
    printf(fmt1, "profiles with EN forced", n_profiles_en)
    printf(fmt1, "profiles with FR forced", n_profiles_fr)
    printf(fmt1, "multilingual profiles", n_profiles_ml)

    n_box_en = Legacy::Box.with_content.free_text.where(cvlang: "en", sciper: scipers_en).count
    n_box_fr = Legacy::Box.with_content.free_text.where(cvlang: "fr", sciper: scipers_fr).count
    n_box_ml = Legacy::Box.with_content.free_text.where(sciper: scipers_ml).count
    n_box_ml_en = Legacy::Box.with_content.free_text.where(cvlang: "en", sciper: scipers_ml).count
    n_box_ml_fr = Legacy::Box.with_content.free_text.where(cvlang: "fr", sciper: scipers_ml).count

    n_sciper_box_en = Legacy::Box.with_content.free_text
                                 .select(:sciper).where(cvlang: "en", sciper: scipers_en).distinct.count(:sciper)
    n_sciper_box_fr = Legacy::Box.with_content.free_text
                                 .select(:sciper).where(cvlang: "fr", sciper: scipers_fr).distinct.count(:sciper)
    n_sciper_box_ml = Legacy::Box.with_content.free_text.select(:sciper).where(
      sciper: scipers_ml
    ).distinct.count
    n_sciper_box_ml_en = Legacy::Box.with_content.free_text.where(
      cvlang: "en",
      sciper: scipers_ml
    ).distinct.count
    n_sciper_box_ml_fr = Legacy::Box.with_content.free_text.where(
      cvlang: "fr",
      sciper: scipers_ml
    ).distinct.count

    printf("\n----------------- Number of non-empty text boxes\n")
    printf(fmt2, "for EN forced profiles", n_box_en, n_sciper_box_en)
    printf(fmt2, "for FR forced profiles", n_box_fr, n_sciper_box_fr)

    printf(fmt2, "in EN for multilingual", n_box_ml_en, n_sciper_box_ml_en)
    printf(fmt2, "in FR for multilingual", n_box_ml_fr, n_sciper_box_ml_fr)
    printf(fmt2, "for multilingual", n_box_ml, n_sciper_box_ml)

    printf("\n----------------- Number of distinct multilingual scipers\n")

    dsci_a = Legacy::Box.with_content.free_text.select(:sciper).where(sciper: scipers_ml).distinct.map(&:sciper)
    printf(fmt1, "with soemthing in a free content box", dsci_a.count)

    f = %w[edu_show photo_ts web_perso nat origine tel_prive]
    q = f.map { |s| "#{s} is not NULL and #{s} <> ''" }.join(" or ")
    dsci_b = Legacy::Cv.select(:sciper).where(sciper: scipers_ml).where(q).distinct.map(&:sciper)
    printf(fmt1, "with something in one of the content columns of Cv", dsci_b.count)

    dsci_c = Legacy::TranslatedCv.select(:sciper).where(sciper: scipers_ml)
                                 .where("datemod > datecr").distinct.map(&:sciper)
    printf(fmt1, "with modification date > creation date for the TranslatedCv", dsci_c.count)

    dsci_d = Legacy::Education.select(:sciper).where(sciper: scipers_ml).distinct.map(&:sciper)
    printf(fmt1, "with an entry in education table", dsci_d.count)

    dsci_e = Legacy::Experience.select(:sciper).where(sciper: scipers_ml).distinct.map(&:sciper)
    printf(fmt1, "with an entry in experiences (parcours) table", dsci_e.count)

    dsci_f = Legacy::Publication.select(:sciper).where(sciper: scipers_ml).distinct.map(&:sciper)
    printf(fmt1, "with an entry in publications table", dsci_f.count)

    dsci_g = Legacy::SocialId.select(:sciper).where(sciper: scipers_ml)
                             .where.not(content: [nil, ""]).distinct.map(&:sciper)

    printf(fmt1, "with an entry research_id table", dsci_g.count)

    dsci = (dsci_a + dsci_b + dsci_c + dsci_d + dsci_e + dsci_f + dsci_g).uniq
    printf(fmt1, "combining all the above", dsci.count)
  end
end
