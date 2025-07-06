# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.8"

# ---------------------------------------------------- Standard (from rails new)

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", ">= 2.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Dart SASS [https://github.com/rails/dartsass-rails]
gem "dartsass-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
gem "solid_queue"
# gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"
# gem 'mini_magick', '~> 4.11'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem 'mocha'
  gem "selenium-webdriver"
  gem 'simplecov'
end

# ----------------------------------------- version bumps due to security issues
#                       (https://github.com/epfl-si/people2/security/dependabot)

gem "cgi", ">= 0.3.7"
gem "json", ">= 2.10.2"
gem "nokogiri", ">= 1.18.3"
gem "rack", ">= 3.1.12"
gem "uri", ">= 0.12.4"

# ------------------------------------------------------------------------ Added

# https://github.com/palkan/action_policy
gem "action_policy"
# gem 'activeresource'
# gem 'cached_resource'

gem 'async'
gem 'cld'

gem 'csv'

# Database adapters
# NOTE: Tim is writing an API for ISA. Therefore we might be able to get rid of this
# gem 'activerecord-oracle_enhanced-adapter', '~> 7.0.0'

gem 'mysql2'

gem 'net-ldap'

gem 'rack-cors'

# TODO: most probably ollama-ai and openai are redundant. We will have to pick one
# Ollama LLM AI for translation and language detection
# https://github.com/gbaptista/ollama-ai
gem 'ollama-ai'

# TODO: figure out why bundle install during docker build fails
# gem "openai", github: "openai/openai-ruby", branch: "main"
# gem 'opdo_epfl_spymiddleware', git: 'https://github.com/epfl-si/opdo-rails', branch: 'fix/people_compatibility'
gem 'openai', path: 'vendor/gems/openai-ruby'
# gem 'opdo_epfl_spymiddleware', path: 'vendor/gems/opdo-rails'

gem 'ostruct'

gem "mission_control-jobs"

# PaperTrail for tracking changes to models
# https://github.com/paper-trail-gem/paper_trail
gem 'paper_trail', '~> 16'

# Positioning replaces acts_as_list by the same author
# https://github.com/brendon/positioning
gem 'positioning'

# Avoid a warning message from rubyzip about broken compatibility of >=3.0
# TODO: recheck if this is still the case
gem 'rubyzip', '< 3.0'

# ----
# Load environment from .env
# gem 'dotenv-rails', group: :development

# # GraphQL server
# gem 'graphiql-rails', group: :development
# gem 'graphql', '~> 2.0'

# # Requirements for an OpenID-Connect Resource Server
# gem 'rails_warden', '~> 0.6.0'
# gem 'warden_openid_bearer', '~> 0.1.3'
# ----
gem 'connection_pool'
gem 'database_cleaner-active_record'

# https://dev.37signals.com/kamal-prometheus/
# https://betterstack.com/community/guides/monitoring/ruby-rails-prometheus/
# https://github.com/yabeda-rb/yabeda-rails
gem "yabeda"
gem "yabeda-prometheus-mmap"
gem "yabeda-puma-plugin"
gem "yabeda-rails"

group :development do
  # security tools
  gem 'brakeman'
  gem 'bundler-audit'

  gem 'faker'

  # TODO: I wanted to give google translate a try but I cannot figure out how to
  #       evaluate pricing and to generate the api key.
  # gem 'google-cloud-translate', '~> 3.2', '>= 3.2.2'

  # Used to generate mock data:
  gem 'prime', '~> 0.1.2'

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
  # gem 'guard', require: false

  gem "webmock"
end
