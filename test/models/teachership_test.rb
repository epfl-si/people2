# frozen_string_literal: true

require 'test_helper'

class TeachershipTest < ActiveSupport::TestCase
  def setup
    @teachership_e1 = teacherships(:e1)
    @teachership_g1 = teacherships(:g1)
    @teachership_m1 = teacherships(:m1)
  end

  test "should belong to a course" do
    assert_equal courses(:cs311), @teachership_e1.course, "Teachership should belong to the correct course"
    assert_equal courses(:phys201), @teachership_g1.course, "Teachership should belong to the correct course"
  end

  test "should belong to a teacher" do
    assert_equal profiles(:edouard), @teachership_e1.teacher, "Teachership should belong to the correct teacher"
    assert_equal profiles(:giovanni), @teachership_g1.teacher, "Teachership should belong to the correct teacher"
  end

  test "should correctly assign sciper, role, and kind" do
    assert_equal "2291051", @teachership_e1.sciper, "Teachership should have the correct sciper"
    assert_equal "Professeur ordinaire", @teachership_e1.role, "Teachership should have the correct role"
    assert_equal "Enseignant", @teachership_e1.kind, "Teachership should have the correct kind"
  end
end
