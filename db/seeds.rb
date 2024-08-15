# frozen_string_literal: true

# Remember to make reseed in order to refresh

SEEDS_DIR = ENV.fetch('SEEDS_PATH', 'db/seeds/data')
DEV_SEEDS_DIR = ENV.fetch('DEV_SEEDS_PATH', 'db/seeds_dev/data')
LANGS = %w[en fr].freeze

if Rails.env.development?
  Dir[Rails.root.join('db/seeds_dev/*.rb').to_s].sort.each do |seed|
    load seed
  end
end

Dir[Rails.root.join('db/seeds/*.rb').to_s].sort.each do |seed|
  load seed
end
