# frozen_string_literal: true

SEEDS_DIR = ENV.fetch('SEEDS_PATH', 'db/seeds/data')
DEV_SEEDS_DIR = ENV.fetch('DEV_SEEDS_PATH', 'db/seeds_dev/data')
LANGS = %w[en fr].freeze

Rake.application['db:fixtures:load'].invoke if Rails.env.development?

Dir[Rails.root.join('db/seeds/*.rb').to_s].sort.each do |seed|
  load seed
end

if Rails.env.development?
  Dir[Rails.root.join('db/seeds_dev/*.rb').to_s].sort.each do |seed|
    load seed
  end
end
