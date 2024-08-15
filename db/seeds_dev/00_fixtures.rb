# frozen_string_literal: true

Rake.application['db:fixtures:load'].invoke

# I keep the comments below as reminder of what NOT to try to do!

# Please do not blame me for the following code: it is just copied from
# https://github.com/rails/rails/blob/main/activerecord/lib/active_record/railties/databases.rake
# It was supposed to work by just setting FIXTURES_DIR and invoking but
# it does not work. No time to investigate why...
# ENV['FIXTURES_DIR']='/../../db/dev_seeds/fixtures'
# Rake.application['db:fixtures:load'].invoke
# Note: I didn't find a way to change the location of fixture blob files.
#       Therefore files (profile images) are still in test/fixtures/files
# fixtures_dir = Rails.root.join('db/seeds_dev/fixtures')

# fixture_files = Dir[File.join(fixtures_dir, "**/*.{yml}")]
# fixture_files.reject! { |f| f.start_with?(File.join(fixtures_dir, "files")) }
# fixture_files.map! { |f| f[fixtures_dir.to_s.size..-5].delete_prefix("/") }

# ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixture_files)
