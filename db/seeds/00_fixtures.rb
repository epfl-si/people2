# frozen_string_literal: true

# This is taken from activerecord/lib/active_record/railties/databases.rake
fixtures_dir = Rails.root.join("db/seeds/fixtures").to_s
fixture_files = Dir["#{fixtures_dir}/**/*.yml"].map { |f| f[(fixtures_dir.size + 1)..-5] }
ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixture_files)
