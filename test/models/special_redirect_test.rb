# frozen_string_literal: true

require "test_helper"

class SpecialRedirectTest < ActiveSupport::TestCase
  test "for_sciper_or_name returns the first special option" do
    original_method = SpecialOption.method(:for_sciper_or_name)
    SpecialOption.define_singleton_method(:for_sciper_or_name) do |_v|
      [OpenStruct.new(name: "redirect_1")]
    end

    result = SpecialRedirect.for_sciper_or_name("some_value")
    assert_equal "redirect_1", result.name
  ensure
    SpecialOption.define_singleton_method(:for_sciper_or_name, original_method)
  end

  test "url returns the data" do
    redirect = SpecialRedirect.new
    redirect.define_singleton_method(:data) { "https://example.com" }

    assert_equal "https://example.com", redirect.url
  end
end
