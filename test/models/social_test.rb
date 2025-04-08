# frozen_string_literal: true

require 'test_helper'

class SocialTest < ActiveSupport::TestCase
  test "url generates the correct URL based on tag and value" do
    profile = Profile.new(sciper: "123456")
    social = Social.new(
      tag: "orcid",
      value: "0000-0002-1825-0097",
      profile: profile
    )

    expected_url = "https://orcid.org/0000-0002-1825-0097"
    assert_equal expected_url, social.url
  end

  test "value format is validated for invalid ORCID" do
    profile = Profile.new(sciper: "123456")
    social = Social.new(
      tag: "orcid",
      value: "not-a-valid-orcid",
      profile: profile
    )

    def social.automatic?
      false
    end

    assert_not social.valid?
    assert_includes social.errors[:value], I18n.t("activerecord.errors.models.social.attributes.value.incorrect_format")
  end

  test "value format is valid for a correct Google Scholar ID" do
    profile = Profile.new(sciper: "123456")
    social = Social.new(
      tag: "googlescholar",
      value: "abcdEFGhiJKLMno",
      profile: profile
    )

    assert social.valid?, "Should be valid with a correctly formatted Google Scholar ID"
  end

  test "url_prefix removes the placeholder from the pattern" do
    profile = Profile.new(sciper: "123456")
    social = Social.new(
      tag: "github",
      value: "myusername",
      profile: profile
    )

    assert_equal "https://github.com/", social.url_prefix
  end
end
