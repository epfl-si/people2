# frozen_string_literal: true

require 'test_helper'

class EducationTest < ActiveSupport::TestCase
  fixtures :educations

  def setup
    @gio_edu_uni = educations(:gio_edu_uni)
    @gio_edu_phd = educations(:gio_edu_phd)
  end

  test "should validate presence of school" do
    I18n.locale = :en
    @gio_edu_uni.school = nil
    assert_not @gio_edu_uni.valid?, "Education without school should be invalid"
    assert_includes @gio_edu_uni.errors[:school], I18n.t('activerecord.errors.models.education.attributes.school.blank')

    I18n.locale = :fr
    @gio_edu_uni.school = nil
    assert_not @gio_edu_uni.valid?, "Education without school should be invalid"
    assert_includes @gio_edu_uni.errors[:school], I18n.t('activerecord.errors.models.education.attributes.school.blank')
  end

  test "should validate presence of year_begin and year_end" do
    I18n.locale = :en
    @gio_edu_uni.year_begin = nil
    assert_not @gio_edu_uni.valid?, "Education without year_begin should be invalid"
    assert_includes @gio_edu_uni.errors[:year_begin],
                    I18n.t('activerecord.errors.models.education.attributes.year_begin.blank')

    @gio_edu_uni.year_begin = 1990
    @gio_edu_uni.year_end = nil
    assert_not @gio_edu_uni.valid?, "Education without year_end should be invalid"
    assert_includes @gio_edu_uni.errors[:year_end],
                    I18n.t('activerecord.errors.models.education.attributes.year_end.blank')

    I18n.locale = :fr
    @gio_edu_uni.year_begin = nil
    assert_not @gio_edu_uni.valid?, "Education without year_begin should be invalid"
    assert_includes @gio_edu_uni.errors[:year_begin],
                    I18n.t('activerecord.errors.models.education.attributes.year_begin.blank')

    @gio_edu_uni.year_begin = 1990
    @gio_edu_uni.year_end = nil
    assert_not @gio_edu_uni.valid?, "Education without year_end should be invalid"
    assert_includes @gio_edu_uni.errors[:year_end],
                    I18n.t('activerecord.errors.models.education.attributes.year_end.blank')
  end

  test "should be positioned correctly within profile" do
    educations = @gio_edu_uni.profile.educations.order(:position)
    assert_equal [@gio_edu_uni, @gio_edu_phd], educations, "Educations should be positioned correctly"
  end

  test "should correctly handle audience visibility" do
    assert @gio_edu_uni.visible?, "Education :gio_edu_uni should be visible"
    assert @gio_edu_phd.visible?, "Education :gio_edu_phd should be visible"
  end
end
