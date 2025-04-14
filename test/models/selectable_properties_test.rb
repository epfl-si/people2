# frozen_string_literal: true

require 'test_helper'

class SelectablePropertyTest < ActiveSupport::TestCase
  def setup
    Award.delete_all
    SelectableProperty.delete_all

    SelectableProperty.instance_variable_set(:@all_by_property, nil)
  end

  test "all_by_property groups records by property" do
    sp1 = SelectableProperty.create!(
      label: "a1",
      name_en: "X",
      property: "award_category"
    )

    sp2 = SelectableProperty.create!(
      label: "a3",
      name_en: "Z",
      property: "award_category"
    )

    sp3 = SelectableProperty.create!(
      label: "o1",
      name_en: "Y",
      property: "award_origin"
    )

    grouped = SelectableProperty.all_by_property
    assert_equal [sp1, sp2], grouped["award_category"].sort_by(&:label)
    assert_equal [sp3], grouped["award_origin"]
  end

  test "award_category returns correct records" do
    sp1 = SelectableProperty.create!(
      label: "c1",
      name_en: "M",
      property: "award_category"
    )

    sp2 = SelectableProperty.create!(
      label: "c2",
      name_en: "N",
      property: "award_origin"
    )

    result = SelectableProperty.award_category
    assert_includes result, sp1
    assert_not_includes result, sp2
  end
end
