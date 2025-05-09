# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

# TODO: the next two tasks which are very very inefficients can be replaced
#       by litle more than
#       ./bin/api.sh \
#          "authorizations?authid=botweb&status=active&type=property" \
#          | jq '.authorizations[].persid'
#       which gets the scipers of all people with botweb property.
namespace :legacy do
  desc 'Count unique scipers and save the list in work database'
  task seed_scipers: :environment do
    scipers = Legacy::Cv.connection.select_all("
      SELECT DISTINCT sciper FROM common
      UNION
      SELECT DISTINCT sciper FROM cv
      UNION
      SELECT DISTINCT sciper FROM accreds
    ").to_a.map { |v| v["sciper"] }
    puts "There are #{scipers.count} unique scipers"
    puts "Here are the first and last 10:"
    puts scipers.first(10).join(", ")
    puts scipers.last(10).join(", ")
    puts "Importing into work db"
    if Work::Sciper.count.zero?
      # rubocop:disable Rails/SkipsModelValidations
      Work::Sciper.insert_all(scipers.map { |s| { sciper: s } })
      # rubocop:enable Rails/SkipsModelValidations
    else
      done = Work::Sciper.all.map { |s| s.sciper.to_s }
      (scipers - done).each do |sciper|
        Work::Sciper.find_or_create_by(sciper: sciper)
      end
    end
  end

  desc 'Check which scipers are still valid and eligible to have a people account'
  task check_botweb: :environment do
    lds_file = "tmp/ldap_scipers.txt"
    # TODO: untested
    unless File.exist?(lds_file)
      cmd = "ldapsearch -x -h ldap.epfl.ch -b 'o=epfl,c=ch' objectClass=person uniqueidentifier"
      cmd += "| awk '/^uniqueIdentifier/{print $2;}' | sort | uniq > #{lds_file}"
      system(cmd)
    end
    ldap_scipers = File.readlines(Rails.root.join(lds_file)).map { |l| [l.chomp, true] }.to_h

    total = Work::Sciper.count
    done = Work::Sciper.treated.count
    puts "Treated #{done} / #{total}"
    while done < total
      ss = Work::Sciper.where(status: 0).take(100)
      ss.each do |s|
        if ldap_scipers[s.sciper].present?
          bb = Authorisation.property_for_sciper(s.sciper, "botweb")
          s.status = if bb.empty?
                       2
                     else
                       3
                     end
        else
          s.status = 1
        end
      end
      Work::Sciper.transaction do
        ss.each(&:save)
      end
      done += 100
      puts "Treated #{done} / #{total}"
    end
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
