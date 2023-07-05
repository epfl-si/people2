SEEDS_DIR=ENV.fetch('SEEDS_PATH', "db/seeds/data")
DEV_SEEDS_DIR=ENV.fetch('DEV_SEEDS_PATH', "db/seeds_dev/data")
LANGS=["en", "fr"]

if Rails.env.development?
  Rake.application["db:fixtures:load"].invoke
end

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  load seed
end

if Rails.env.development?
  Dir[File.join(Rails.root, 'db', 'seeds_dev', '*.rb')].sort.each do |seed|
    load seed
  end
end
