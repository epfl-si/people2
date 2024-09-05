# frozen_string_literal: true

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :courses

  def setup
    @cs308 = courses(:cs308)
    @com516 = courses(:com516)
    @phys201 = courses(:phys201)
  end

  test "edu_url should handle cases with missing code" do
    assert_nil @cs308.edu_url(:en), "edu_url should return nil if code is missing"
  end

  test "edu_url should return correct URL format" do
    expected_url = "https://edu.epfl.ch/coursebook/en/general-physics-electromagnetism-PHYS-201-C"
    assert_equal expected_url, @phys201.edu_url(:en), "edu_url should return correct URL format"
  end

  test "edu_url should handle cases with missing title" do
    assert_nil @com516.edu_url(:en), "edu_url should return nil if title is missing"
  end
end
