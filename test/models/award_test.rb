# frozen_string_literal: true

require "test_helper"

class AwardTest < ActiveSupport::TestCase
  test "Should not save Award without mandatory parameters" do
    award = awards(:edo_awa)
    assert award.valid?, "Fixture Award :edo_ewa is supposed to be valid #{award.errors.inspect}"

    award.year = nil
    assert_not award.save, "Saved award without year"
    award.year = Time.zone.today.year
    assert award.save, "Award with year should be valid and saved"

    award.issuer = nil
    assert_not award.save, "Saved award without issuer"
    award.issuer = "Ciccio"
    assert award.save, "Award with issuer should be valid and saved"
  end
  test "Should not save Award without year in the future" do
    award = awards(:edo_awa)
    award.year = Time.zone.today.year + 10
    assert_not award.save, "Saved award without year in the future"
  end

  test "Should not validate when property is not of the right kind" do
    award = awards(:edo_awa)
    award.category_id = award.origin_id
    assert_not award.save, "Save with invalid category_id"

    award = awards(:edo_awa)
    award.origin_id = award.category_id
    assert_not award.save, "Save with invalid origin_id"
  end
end
