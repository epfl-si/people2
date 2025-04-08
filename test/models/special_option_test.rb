# frozen_string_literal: true

require 'test_helper'

class SpecialOptionTest < ActiveSupport::TestCase
  setup do
    SpecialMail.delete_all
  end

  test "for returns all options for a given sciper" do
    SpecialMail.create!(sciper: 123_456, data: "john@example.com")
    SpecialMail.create!(sciper: 123_456, data: "jane@example.com")

    results = SpecialOption.where(sciper: 123_456)
    assert_equal 2, results.size
  end

  test "for_sciper_or_name returns options by sciper" do
    SpecialMail.create!(sciper: 123_456, data: "mail1@example.com")
    SpecialMail.create!(sciper: 789_123, data: "mail2@example.com")

    results = SpecialOption.for_sciper_or_name(123_456)
    assert_equal 1, results.count
    assert_equal "mail1@example.com", results.first.data
  end

  test "for_sciper_or_name returns options by ns" do
    SpecialMail.create!(sciper: 123_456, ns: "john", data: "mail@example.com")

    results = SpecialOption.for_sciper_or_name("john")
    assert_equal 1, results.count
    assert_equal "mail@example.com", results.first.data
  end
end
