# frozen_string_literal: true

require 'test_helper'

class SelectablePropertyTest < ActiveSupport::TestCase
  def setup
    @major_award = selectable_properties(:ac_majour)
    @discipline_award = selectable_properties(:ac_discipline)
    @best_award = selectable_properties(:ac_best)
    @epfl_origin = selectable_properties(:ao_epfl)
    @swiss_origin = selectable_properties(:ao_suisse)
    @international_origin = selectable_properties(:ao_international)
  end

  test 'should return correct English name' do
    assert_equal 'Major award, medal or prize', @major_award.name_en, 'English name should be correct for major award'
  end

  test 'should return correct French name' do
    assert_equal 'Prix important, medaille', @major_award.name_fr, 'French name should be correct for major award'
  end

  test 'award_category scope should return correct records' do
    award_categories = SelectableProperty.award_category

    assert_includes award_categories, @major_award, 'Major award should be in award categories'
    assert_includes award_categories, @discipline_award, 'Discipline award should be in award categories'
    assert_includes award_categories, @best_award, 'Best publication award should be in award categories'
    assert_not_includes award_categories, @epfl_origin, 'EPFL origin should not be in award categories'
  end

  test 'award_origin scope should return correct records' do
    award_origins = SelectableProperty.award_origin

    assert_includes award_origins, @epfl_origin, 'EPFL origin should be in award origins'
    assert_includes award_origins, @swiss_origin, 'Swiss origin should be in award origins'
    assert_includes award_origins, @international_origin, 'International origin should be in award origins'
    assert_not_includes award_origins, @major_award, 'Major award should not be in award origins'
  end
end
