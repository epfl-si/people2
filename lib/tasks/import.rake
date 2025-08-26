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
    Profile.for_sciper(sciper).destroy
    per = Person.find(sciper)
    per.profile!
    if (m = Adoption.where(sciper: sciper)&.first)
      m.accepted = false
      m.save
      # Refresh legacy pache proxy cache
      m.content('en', force: true)
      m.content('fr', force: true)
    end
  end
end
