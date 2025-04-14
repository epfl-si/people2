# frozen_string_literal: true

require "test_helper"

class InfoscienceTest < ActiveSupport::TestCase
  test "sanitize_url formats a valid Infoscience URL correctly" do
    i = Infoscience.new(url: " https://infoscience-exports.epfl.ch/12345 ")
    i.valid?

    assert_equal "https://infoscience-exports.epfl.ch/12345/", i.url
  end

  test "sanitize_url does nothing on already correct URL" do
    i = Infoscience.new(url: "https://infoscience-exports.epfl.ch/98765/")
    i.valid?

    assert_equal "https://infoscience-exports.epfl.ch/98765/", i.url
  end

  test "url_format adds error if URL is invalid" do
    i = Infoscience.new(url: "https://google.com/whatever")
    i.valid?
    assert i.errors[:url].any?, "Expected validation error on :url"
  end

  test "url_format accepts valid Infoscience URL" do
    i = Infoscience.new(url: "https://infoscience-exports.epfl.ch/77777")
    i.valid?

    assert_empty i.errors[:url]
  end

  test "sciper is delegated to profile" do
    profile = Profile.new(sciper: "999999")
    i = Infoscience.new(profile: profile)

    assert_equal "999999", i.sciper
  end

  test "t_content calls InfoscienceGetter with url" do
    url = "https://infoscience-exports.epfl.ch/12345/"
    i = Infoscience.new(url: url)

    called_args = nil

    InfoscienceGetter.define_singleton_method(:call) do |args|
      called_args = args
      { "title" => "Fake Data" }
    end

    content = i.t_content

    assert_equal({ url: url }, called_args)
    assert_equal "Fake Data", content["title"]
  ensure
    InfoscienceGetter.singleton_class.remove_method(:call)
  end
end
