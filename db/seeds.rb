# frozen_string_literal: true

# Remember to make reseed in order to refresh

ENV['FIXTURES_DIR'] = "../../db/seeds/fixtures"
Rake.application['db:fixtures:load'].invoke

dir = Rails.env.development? ? "seeds_dev" : "seeds"
Dir[Rails.root.join("db/#{dir}/*.rb").to_s].sort.each do |seed|
  load seed
end
