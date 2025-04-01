# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class AccredTest < ActiveSupport::TestCase
  fixtures :accreds, :profiles

  test "should not allow hiding all accreds for a profile" do
    accreds = Accred.where(visible: true).group_by(&:profile)

    accreds.each do |profile, visible_accreds|
      next if visible_accreds.count > 1

      accred = visible_accreds.first
      accred.visible = false
      assert_not accred.save, "Should not allow hiding the last visible accred for profile #{profile.id}"
    end
  end

  test "for_profile! should return accreditations prefs for profile" do
    profile = profiles(:valid_profile)

    stubbed_accreditations = [
      OpenStruct.new(prefs: { unit: "test-unit-1" }),
      OpenStruct.new(prefs: { unit: "test-unit-2" })
    ]

    original_method = Accreditation.method(:for_profile!)

    Accreditation.define_singleton_method(:for_profile!) do |*|
      stubbed_accreditations
    end

    prefs = Accred.for_profile!(profile)

    assert prefs.is_a?(Array), "for_profile! should return an array"
    assert_equal 2, prefs.size, "Should return 2 prefs elements"
    assert_equal(%w[test-unit-1 test-unit-2], prefs.map { |p| p[:unit] })
  ensure
    Accreditation.define_singleton_method(:for_profile!, original_method)
  end
end
