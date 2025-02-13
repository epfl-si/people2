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
  desc 'Import profiles from legacy DB'
  task import: :environment do
    if Rails.env.development?
      SCIPERS.each do |sciper|
        profile = Profile.for_sciper(sciper)
        if profile.present?
          puts "Destroying already imported profile #{sciper}"
          profile.destroy
        end
      end
    end
    LegacyProfileImportJob.perform_now(SCIPERS)
  end
end
