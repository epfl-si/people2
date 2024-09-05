# frozen_string_literal: true

require 'test_helper'

class ExperienceTest < ActiveSupport::TestCase
  fixtures :experiences

  def setup
    @giova_exp_algo = experiences(:giova_exp_algo)
    @giova_exp_kandou = experiences(:giova_exp_kandou)
    @giova_exp_vpsi = experiences(:giova_exp_vpsi)
  end

  test "should validate presence of location" do
    experience = Experience.new(location: nil, year_begin: 2000, year_end: 2005)
    assert_not experience.valid?, "Experience without location should be invalid"
    assert_includes experience.errors[:location],
                    I18n.t('activerecord.errors.models.experience.attributes.location.blank')
  end

  test "should validate presence of year_begin and year_end" do
    experience = Experience.new(location: 'EPFL', year_begin: nil, year_end: nil)

    Experience.skip_callback(:validation, :before, :complete_period)

    assert_not experience.valid?, "Experience without year_begin and year_end should be invalid"
    assert_includes experience.errors[:year_begin],
                    I18n.t('activerecord.errors.models.experience.attributes.year_begin.blank')
    assert_includes experience.errors[:year_end],
                    I18n.t('activerecord.errors.models.experience.attributes.year_end.blank')

    Experience.set_callback(:validation, :before, :complete_period)
  end

  test "should complete period with year_end if year_begin is nil" do
    experience = Experience.new(year_begin: nil, year_end: 2019, location: 'EPFL', title_en: "DevOps",
                                title_fr: "DevOps")
    experience.valid? # Trigger before_validation
    assert_equal experience.year_end, experience.year_begin, "year_begin should be set to year_end if it is nil"
  end

  test "should complete period with year_begin if year_end is nil" do
    experience = Experience.new(year_begin: 2017, year_end: nil, location: 'EPFL', title_en: "DevOps",
                                title_fr: "DevOps")
    experience.valid? # Trigger before_validation
    assert_equal experience.year_begin, experience.year_end, "year_end should be set to year_begin if it is nil"
  end

  test "should be positioned correctly within profile" do
    experiences = @giova_exp_algo.profile.experiences.order(:position)
    assert_equal [@giova_exp_algo, @giova_exp_kandou, @giova_exp_vpsi], experiences,
                 "Experiences should be positioned correctly"
  end

  test "should correctly handle audience visibility" do
    assert @giova_exp_algo.visible?, "Experience :giova_exp_algo should be visible"
    assert @giova_exp_kandou.visible?, "Experience :giova_exp_kandou should be visible"
    assert @giova_exp_vpsi.visible?, "Experience :giova_exp_vpsi should be visible"
  end
end
