# frozen_string_literal: true

require "test_helper"

class PositionFilterTest < ActiveSupport::TestCase
  test "valid? returns true for a valid OR filter" do
    filter = PositionFilter.new("aaa or bbb or ccc")
    assert_predicate filter, :valid?
  end

  test "valid? returns true for a valid AND filter" do
    filter = PositionFilter.new("aaa and bbb and ccc")
    assert_predicate filter, :valid?
  end

  test "valid? returns true for a simple token" do
    filter = PositionFilter.new("aaa")
    assert_predicate filter, :valid?
  end

  test "catch_all? returns true for *" do
    filter = PositionFilter.new("*")
    assert_predicate filter, :catch_all?
  end

  test "match? returns true for OR filters if any token matches" do
    filter = PositionFilter.new("aaa or bbb")
    assert filter.match?("aaa")
    assert filter.match?("bbb")
    refute filter.match?("ccc")
  end

  test "match? returns true if input matches all tokens with AND" do
    filter = PositionFilter.new("aaa and bbb")
    assert filter.match?("aaa bbb"), "Should match both 'aaa' and 'bbb' in the same string"
    refute filter.match?("aaa"), "Should not match only 'aaa'"
    refute filter.match?("bbb"), "Should not match only 'bbb'"
    refute filter.match?("ccc"), "Should not match unrelated token 'ccc'"
  end

  test "match? handles negated tokens with AND (adjusted)" do
    filter = PositionFilter.new("aaa and !bbb")
    assert filter.match?("aaa"), "Should match 'aaa'"
    refute filter.match?("bbb"), "Should not match 'bbb'"
  end

  test "match? returns true for * catch_all" do
    filter = PositionFilter.new("*")
    assert filter.match?("whatever")
    assert filter.match?("anything else")
  end

  test "match? returns false if no token matches in OR filter" do
    filter = PositionFilter.new("aaa or bbb")
    refute filter.match?("zzz")
  end
end
