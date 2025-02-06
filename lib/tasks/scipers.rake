# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

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
end
