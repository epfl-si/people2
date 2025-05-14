# frozen_string_literal: true

namespace :admin do
  desc 'Drop all translations table data (CAUTION!!) and reload from source'
  task reseed_translations: :environment do
    Admin::Translation.in_batches(of: 100).delete_all
    Admin::Translation.reload_source_files
  end
end
