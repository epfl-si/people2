# frozen_string_literal: true

require 'test_helper'

class ExperienceTest < ActiveSupport::TestCase
  test "complete_period copies year_end to year_begin if year_begin is nil" do
    exp = Experience.new(year_end: 2020, year_begin: nil)
    exp.valid?

    assert_equal 2020, exp.year_begin
    assert_equal 2020, exp.year_end
  end

  test "complete_period copies year_begin to year_end if year_end is nil" do
    exp = Experience.new(year_begin: 2018, year_end: nil)
    exp.valid?

    assert_equal 2018, exp.year_end
    assert_equal 2018, exp.year_begin
  end

  test "complete_period does not override when both years are set" do
    exp = Experience.new(year_begin: 2015, year_end: 2020)
    exp.valid?

    assert_equal 2015, exp.year_begin
    assert_equal 2020, exp.year_end
  end
end
