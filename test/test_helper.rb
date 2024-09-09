# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# https://nicolasiensen.github.io/2022-03-11-running-rails-system-tests-with-docker/
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://webapp:#{Capybara.server_port}"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
