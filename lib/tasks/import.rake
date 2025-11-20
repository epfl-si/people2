# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

SCIPERS = [
  '102717', # a prof with achievements
  '124369', # Rudi who has various free text boxes
  '182447', # Her
  '334422', # Asked by Natalie
  '103938', # Asked by Natalie
  '105611'  # Asked by Natalie
].freeze

namespace :legacy do
  desc <<~IMPORT_DESC
    Import profiles from legacy DB (-D/--describe for detailed usage)
    In development, this will import just short list of
    hardcoded representative profiles.
    In production it will import all the migranda profiles. Parameters:
      MAX only import upto MAX profiles;
      BAS the profiles are assigned to separate jobs in batches of BAS items
      example:
      MAX=1000 BAS=50 ./bin/rails legacy:import
    Development can be forcedo to work like production by setting ALL. Example:
      ALL=1 MAX=1000 BAS=50 ./bin/rails legacy:import
  IMPORT_DESC
  task import: :environment do
    if Rails.env.development?
      SCIPERS.each do |sciper|
        profile = Profile.for_sciper(sciper)
        if profile.present?
          puts "Destroying already imported profile #{sciper}"
          profile.destroy
        end
      end
      LegacyProfileImportJob.perform_now(SCIPERS)
    end
    if Rails.env.production? || ENV['ALL']
      # Work::Sciper.migranda.in_batches(of: 100) do |ss|
      #   scipers = ss.map(&:sciper).join(", ")
      #   LegacyProfileImportJob.perform_now(scipers)
      # end
      ss = Work::Sciper.migranda.pluck(:sciper) - Profile.all.pluck(:sciper)
      max = ENV['MAX']&.to_i
      bas = ENV['BAS']&.to_i || 10
      ss = ss[..max] if max.present?
      ss.each_slice(bas) { |s| LegacyProfileImportJob.perform_later(s) }
    end
  end

  desc 'Destroy and reimport the profile for a given sciper: SCIPER=123456 ./bin/rails legacy:reimport'
  task reimport: :environment do
    sciper = ENV['SCIPER']
    unless sciper =~ /^\d{6}$/
      puts "Invalid sciper #{sciper}"
      next
    end
    m = Adoption.where(sciper: sciper)&.first
    if m
      m.reimport
      m.content('en', force: true)
      m.content('fr', force: true)
    end
  end

  desc 'Import missing awards due to the fact that we have relaxed some validation on the new model'
  task missing_awards: :environment do
    all_legacy_award_scipers = Legacy::Award.distinct.pluck(:sciper)
    still_valid_scipers = Work::Sciper.where(sciper: all_legacy_award_scipers).pluck(:sciper)
    new_rule = "year is not null and year != '' and title is not null and title != ''"
    old_rule = "
      year is not null and year != ''
      and origin is not null and origin != ''
      and category is not null and category != ''
    "

    importable_awards = Legacy::Award.where(sciper: still_valid_scipers).where(new_rule)

    probably_imported = importable_awards.where(old_rule)

    not_imported_scipers = probably_imported.pluck(:sciper).sort.uniq - Profile.pluck(:sciper).sort.uniq

    if not_imported_scipers.count.positive?
      probably_imported.where(sciper: not_imported_scipers)
    else
      []
    end

    # people(prod)> importable_awards.count
    # => 1128
    # people(prod)> probably_imported.count
    # => 726
    # people(prod)> not_imported_scipers.count
    # => 1
    # people(prod)> for_sure_not_imported.count
    # => 1
    # people(prod)> to_be_imported.count
    # => 403
    # people(prod)> Award.count
    # => 560
    np = 0
    ia = []
    sa = []
    default_category = Award.default_category
    default_origin = Award.default_origin
    still_valid_scipers.each do |sciper|
      law = Legacy::Award.where(sciper: sciper)
      next if law.blank?

      lc = law.count
      pro = Profile.includes(:awards).for_sciper(sciper)
      if pro.blank?
        np += 1
        Rails.logger.debug "\nsciper: #{sciper} no profile, #{lc} awards"
        next
      end
      nc = pro.awards.count
      next if nc >= lc

      Rails.logger.debug "\nsciper: #{sciper} #{nc} / #{lc}"
      if nc.positive?
        pro.awards.each do |a|
          Rails.logger.debug "     #{a.year} / #{a.title_en}"
        end
        Rails.logger.debug "---"
      end
      # law.each do |a|
      #   puts "  L  #{a.year} / #{a.title_en}"
      # end
      law.each do |la|
        a = la.to_award('en', profile: pro, fallback_lang: nil)
        a.origin = default_origin
        a.category = default_category
        unless a.valid?
          ia << la.id
          Rails.logger.debug "  x  #{la.year} / #{la.title}"
          next
        end
        sa << a
        if pro.awards.select do |v|
          v.year == a.year &&
          v.title_en == a.title_en &&
          v.title_en == a.title_en
        end.count.positive?
          Rails.logger.debug "  =  #{a.year} / #{a.title_en}"
        else
          Rails.logger.debug "  +  #{a.year} / #{a.title_en}"
        end
      end
    end
    Rails.logger.debug "no profile count: #{np}"
    Rails.logger.debug "still invalid awards: #{ia.count}: #{ia.join(', ')}"
    Rails.logger.debug "new accreds to be saved #{sa.count}"
    ActiveRecord::Base.transaction { sa.each(&:save) }
  end
end
