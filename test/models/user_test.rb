# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(sciper: "123456", email: "user@example.com", name: "Test User", provider: "oidc")
  end

  test "from_oidc creates or finds a user with sciper from uniqueid" do
    data = {
      "email" => "user@example.com",
      "uniqueid" => "123456",
      "given_name" => "Test",
      "family_name" => "User"
    }

    original_method = User.method(:create_with)
    User.define_singleton_method(:create_with) do |_attrs|
      Class.new do
        def self.find_or_create_by(sciper:)
          User.new(sciper: sciper)
        end
      end
    end

    user = User.from_oidc(data)

    assert_instance_of User, user
    assert_equal "123456", user.sciper
  ensure
    User.define_singleton_method(:create_with, original_method)
  end

  test "from_oidc raises error if email is blank" do
    data = { "email" => nil }

    assert_raises RuntimeError, "Invalid data from oidc auth server" do
      User.from_oidc(data)
    end
  end

  test "from_oidc uses Person.find if no uniqueid or sciper provided" do
    data = {
      "email" => "user@example.com",
      "given_name" => "Test",
      "family_name" => "User"
    }

    original_method = Person.method(:find)
    Person.define_singleton_method(:find) do |_email|
      OpenStruct.new(sciper: "654321")
    end

    original_create_with = User.method(:create_with)
    User.define_singleton_method(:create_with) do |_attrs|
      Class.new do
        def self.find_or_create_by(sciper:)
          User.new(sciper: sciper)
        end
      end
    end

    user = User.from_oidc(data)

    assert_instance_of User, user
    assert_equal "654321", user.sciper
  ensure
    Person.define_singleton_method(:find, original_method)
    User.define_singleton_method(:create_with, original_create_with)
  end

  test "from_oidc raises error if sciper cannot be determined" do
    data = {
      "email" => "user@example.com",
      "given_name" => "Test",
      "family_name" => "User"
    }

    original_method = Person.method(:find)
    Person.define_singleton_method(:find) { |_email| nil }

    assert_raises RuntimeError, "Could not determine user sciper" do
      User.from_oidc(data)
    end
  ensure
    Person.define_singleton_method(:find, original_method)
  end

  test "admin_for_profile? returns true if user is admin for profile" do
    original_method = APIAuthGetter.method(:call)
    APIAuthGetter.define_singleton_method(:call) do |_params|
      [{ "persid" => "123456" }]
    end

    profile = OpenStruct.new(sciper: "654321")
    assert @user.admin_for_profile?(profile)
  ensure
    APIAuthGetter.define_singleton_method(:call, original_method)
  end

  test "admin_for_profile? returns false if user is not admin for profile" do
    original_method = APIAuthGetter.method(:call)
    APIAuthGetter.define_singleton_method(:call) do |_params|
      [{ "persid" => "999999" }]
    end

    profile = OpenStruct.new(sciper: "654321")
    assert_not @user.admin_for_profile?(profile)
  ensure
    APIAuthGetter.define_singleton_method(:call, original_method)
  end

  # temporary test
  test "superuser? returns true if sciper is in superusers list" do
    original_superusers = Rails.configuration.superusers
    Rails.configuration.define_singleton_method(:superusers) { %w[123456 654321] }

    assert @user.superuser?
  ensure
    Rails.configuration.define_singleton_method(:superusers) { original_superusers }
  end

  test "superuser? returns false if sciper is not in superusers list" do
    original_superusers = Rails.configuration.superusers
    Rails.configuration.define_singleton_method(:superusers) { ["999999"] }

    assert_not @user.superuser?
  ensure
    Rails.configuration.define_singleton_method(:superusers) { original_superusers }
  end
end
