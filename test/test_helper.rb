# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'simplecov'

# Start SimpleCov with additional configuration
SimpleCov.start do
  add_filter '/test/' # Exclude test files from coverage

  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Services', 'app/services'
  add_group 'Jobs', 'app/jobs'

  SimpleCov.minimum_coverage 90
end

# Capybara configuration
# https://nicolasiensen.github.io/2022-03-11-running-rails-system-tests-with-docker/
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://webapp:#{Capybara.server_port}"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
