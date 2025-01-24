# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :legacy do
  desc 'Count unique scipers'
  task scipers: :environment do
    cachefile = Rails.root.join("tmp/scipers.json")
    if File.exist?(cachefile)
      t0 = Time.now
      puts "Reading from cache file. Remove #{cachefile} if you want to refresh."
      scipers = JSON.parse(File.read(cachefile))
      t1 = Time.now
    else
      t0 = Time.now
      scipers = Legacy::Cv.connection.select_all("
        SELECT DISTINCT sciper FROM common
        UNION
        SELECT DISTINCT sciper FROM cv
        UNION
        SELECT DISTINCT sciper FROM accreds
      ").to_a
      t1 = Time.now
      puts "Writing scipers to #{cachefile}."
      File.write(cachefile, scipers.to_json)
    end
    puts "Elapsed: #{t1 - t0}"
    puts "There are #{scipers.count} unique scipers"
    puts "Here are the first and last 10:"
    puts scipers.first(10).join(", ")
    puts scipers.last(10).join(", ")
  end

  desc 'Import profiles from legacy DB'
  task import: :environment do
    SCIPERS = ['182447']
    SECROSE = [
      { "bio"      => "B" },
      { "research" => "P" },
      { "contact"  => "K" },
      { "research" => "R" },
      { "teaching" => "T" }
    ]
    sections = Section.all.index_by { |s| s.label }
    mboxes = ModelBox.all.index_by { |b| b.label }
    SCIPERS.each do |sciper|
      cv = Legacy::Cv.find(sciper)
      cv_en = cv.translated_part('en')
      cv_fr = cv.translated_part('fr')

      # ------------------------------------------------- profile
      profile = Profile.new_with_defaults(sciper)
      profile.show_birthday = cv.datenaiss_show == "1"
      profile.show_photo = cv.photo_show == "1"

      profile.nationality_en = cv.nat.strip if cv.nat.strip.present?
      profile.nationality_fr = cv.nat.strip if cv.nat.strip.present?
      profile.show_nationality = cv.nat_show == "1"

      profile.phone = cv.tel_priv.strip if cv.tel_prive.strip.present?
      profile.show_phone = cv.tel_prive_show == "1"

      profile.personal_web_url = cv.web_perso.strip if cv.web_perso.strip.present?
      profile.show_weburl = cv.web_perso_show == "1"
      profile.save

      # TODO: enabled languages for which I need the other branch

      # ------------------------------------------------- rich text boxes

      if cv_en.expertise.present? || cv_fr.expertise.present?
        m = mboxes['expertise']
        b = RichTextBox.from_model(m)
        b.profile = profile
        b.content_fr = cv_fr.expertise if cv_fr.expertise.present?
        b.content_en = cv_en.expertise if cv_en.expertise.present?
        b.save
      end

      if cv.defaultcv.present?
        # If profile have a forced language, we can just take that language and discard the rest
        lang = cv.defaultcv

        SECROSE.each do |sec, pos|
          section = sections[sec]
          # Boxes with sys not null are specialized and their content comes from other tables;
          cv.boxes.visible.with_content.where(position: pos, cvlang: lang, sys: nil).order(:ordre).each do |ob|
            b = RichTextBox.new(visible: true)
            b.profile = profile
            b.section = section
            b.send("content_#{lang}=", ob.content.strip)
            b.send("title_#{lang}=", ob.label.strip)
          end
        end

      else
        # if instead both languages are available how do we know which box in
        # a language corresponds to the same box in another language ?
        #  * try to auto-translate and compare the titles. Other options ?
        #  * just go by order and merge the two languages even though they refer
        #    to completelly different boxes ? The result will anyway look like
        #    the one in the legacy app but will look owfull in the edit interface
        #  For now, lacking a better idea, I take the latter approach.
        SECROSE.each do |sec, pos|
          section = sections[sec]
          en = cv.boxes.visible.with_content.where(position: pos, cvlang: "en", sys: nil).order(:ordre).all
          fr = cv.boxes.visible.with_content.where(position: pos, cvlang: "fr", sys: nil).order(:ordre).all
          while oben = en.shift || obfr = fr.shift
            lang = ob.cvlang
            b = RichTextBox.new(visible: true)
            b.profile = profile
            b.section = section
            if oben.present?
              b.content_en = oben.content.strip
              b.title_en = oben.label.strip
            end
            if obfr.present?
              b.content_fr = obfr.content.strip
              b.title_fr = obfr.label.strip
            end
          end
        end
      end

      # Specialized boxes
      # Education
      if cv.educations.count > 0

      end
    end
  end
end
