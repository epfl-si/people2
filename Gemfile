# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.1.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# For the moment, upgrade to 7.1 is prevented by
# activerecord-oracle_enhanced-adapter which requires rails 7.0
# TODO: check if this is still the case
gem 'rails', '~> 7.0.4'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Database adapters
# NOTE: Tim is writing an API for ISA. Therefore we might be able to get rid of this
gem 'activerecord-oracle_enhanced-adapter', '~> 7.0.0'
gem 'mysql2'
gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
# gem 'jsbundling-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

# Load environment from .env
gem 'dotenv-rails', group: :development

# GraphQL server
gem 'graphiql-rails', group: :development
gem 'graphql', '~> 2.0'

# Requirements for an OpenID-Connect Resource Server
gem 'rails_warden', '~> 0.6.0'
gem 'warden_openid_bearer', '~> 0.1.3'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

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
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  # gem "webdrivers"
end

# Used to generate mock data:
gem 'prime', '~> 0.1.2'

# To enable CORS from keycloak
gem 'rack-cors'

# https://github.com/paper-trail-gem/paper_trail
#
gem 'paper_trail', '~> 14'

# Positioning replaces acts_as_list by the same author
# https://github.com/brendon/positioning
gem 'positioning'

# ------------------------------------------------------------------------------
# To be tested, possibly usefull for increasing security in production:

# https://github.com/rack/rack-attack
# gem 'rack-attack'

# https://github.com/github/secure_headers
# gem 'secure_headers'
