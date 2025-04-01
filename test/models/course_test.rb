# frozen_string_literal: true

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "current_academic_year before August returns previous-current year" do
    date = Date.new(2024, 5, 15)
    assert_equal "2023-2024", Course.current_academic_year(date)
  end

  test "current_academic_year from August onward returns current-next year" do
    date = Date.new(2024, 10, 1)
    assert_equal "2024-2025", Course.current_academic_year(date)
  end

  test "edu_url returns nil if code or translated title is blank" do
    course = Course.new(code: "", title_en: "")
    assert_nil course.edu_url(:en)
  end

  test "edu_url builds correct URL based on locale and code" do
    course = Course.new(
      code: "CS-101",
      title_en: "Introduction to Programming"
    )

    expected_url = "https://edu.epfl.ch/coursebook/en/introduction-to-programming-CS-101"
    assert_equal expected_url, course.edu_url(:en)
  end
end
