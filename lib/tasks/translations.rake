# frozen_string_literal: true

namespace :admin do
  desc 'Drop all translations table data (CAUTION!!) and reload from source'
  task reseed_translations: %i[nuke_translations load_translations] do
  end

  desc 'Delete all UI translations from DB (CAUTION!!)'
  task nuke_translations: :environment do
    Admin::Translation.in_batches(of: 100).delete_all
  end

  desc 'Load UI translations from source files'
  task load_translations: :environment do
    Admin::Translation.load_source_files
  end
end
