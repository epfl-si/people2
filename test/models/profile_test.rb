# frozen_string_literal: true

require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "new_with_defaults initializes with correct default attributes" do
    profile = Profile.new_with_defaults("123456")

    assert_equal "123456", profile.sciper
    refute false, profile.show_birthday
    assert true, profile.show_function
    assert_nil profile.personal_web_url
  end

  test "fallback_translation returns first enabled language" do
    profile = Profile.new(en_enabled: false, fr_enabled: true, it_enabled: true, de_enabled: false)

    assert_equal :fr, profile.fallback_translation
  end

  test "fallback_translation returns fr if nothing enabled" do
    profile = Profile.new(en_enabled: false, fr_enabled: false, it_enabled: false, de_enabled: false)

    assert_equal "fr", profile.fallback_translation
  end
end
