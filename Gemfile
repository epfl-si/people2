# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ">= 3.1.2"

# ------------------------- common standard

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# Got rid of activerecord-oracle_enhanced-adapter which required rails 7.0
# Might need it back for updating usual names.
# Let's hope in the mean time it gains compatibility with rails 7.1
gem "rails", "~> 7.1.3", ">= 7.1.3.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Database adapters
# NOTE: Tim is writing an API for ISA. Therefore we might be able to get rid of this
# gem 'activerecord-oracle_enhanced-adapter', '~> 7.0.0'
gem 'mysql2'
gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# ------------------------- common added

#
# Use Sass to process CSS
# gem "sassc-rails"

# Load environment from .env
# gem 'dotenv-rails', group: :development

# # GraphQL server
# gem 'graphiql-rails', group: :development
# gem 'graphql', '~> 2.0'

# # Requirements for an OpenID-Connect Resource Server
# gem 'rails_warden', '~> 0.6.0'
# gem 'warden_openid_bearer', '~> 0.1.3'

# Used to generate mock data:
gem 'prime', '~> 0.1.2'

# # To enable CORS from keycloak
# gem 'rack-cors'

# https://github.com/paper-trail-gem/paper_trail
#
gem 'paper_trail', '~> 14'

# Positioning replaces acts_as_list by the same author
# https://github.com/brendon/positioning
# gem 'positioning'
# TODO: temporary workaround, check https://github.com/brendon/positioning/pulls
gem 'positioning', path: ".gems/positioning"

# Avoid a warning message from rubyzip about broken compatibility of >=3.0
# TODO: recheck if this is still the case
gem 'rubyzip', '< 3.0'

group :development, :test do
  # ----------------------- standard
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mswin mswin64 mingw x64_mingw]
end

group :development do
  # ----------------------- standard
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # ----------------------- added
  # security tools
  gem 'brakeman'
  gem 'bundler-audit'

  gem 'rails-mermaid_erd'

  # Code Linter / checker
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-graphql', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # unused for the moment but I'd like to keep it just to remember that it exists
  # (a sentimental matter because I was involved in its early development)
  # https://github.com/guard/guard
  gem 'guard', require: false
end

group :test do
  # ----------------------- standard
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
