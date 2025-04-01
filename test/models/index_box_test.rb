# frozen_string_literal: true

require "test_helper"

class IndexBoxTest < ActiveSupport::TestCase
  test "variant returns downcased subkind" do
    box = IndexBox.new(subkind: "Award")
    assert_equal "award", box.variant
  end

  test "plural_variant returns pluralized and downcased subkind" do
    box = IndexBox.new(subkind: "Experience")
    assert_equal "experiences", box.plural_variant
  end

  test "content? returns true when profile has items" do
    profile = Profile.new
    def profile.experiences
      [1, 2, 3]
    end

    box = IndexBox.new(subkind: "Experience", profile: profile)
    assert box.content?
  end

  test "content? returns false when profile has no items" do
    profile = Profile.new
    def profile.experiences
      []
    end

    box = IndexBox.new(subkind: "Experience", profile: profile)
    assert_not box.content?
  end

  test "content_for? returns true when audience-limited items are present" do
    profile = Profile.new

    audience_list = Object.new
    def audience_list.for_audience(_level)
      [1, 2]
    end

    profile.define_singleton_method(:experiences) do
      audience_list
    end

    box = IndexBox.new(subkind: "Experience", profile: profile)
    assert box.content_for?(0)
  end

  test "content_for? returns false when no visible items" do
    profile = Profile.new

    empty_list = Object.new
    def empty_list.for_audience(_level)
      []
    end

    profile.define_singleton_method(:experiences) do
      empty_list
    end

    box = IndexBox.new(subkind: "Experience", profile: profile)
    assert_not box.content_for?(0)
  end
end
