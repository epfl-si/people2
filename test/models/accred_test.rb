# frozen_string_literal: true

require 'test_helper'

class AccredTest < ActiveSupport::TestCase
  fixtures :accreds

  def all_accreds
    Accred.all
  end

  test "all accreds should be valid with valid attributes" do
    all_accreds.each do |accred|
      assert accred.valid?, "Accred with ID #{accred.id} should be valid"
    end
  end

  test "each accred should belong to a profile" do
    all_accreds.each do |accred|
      assert_not_nil accred.profile, "Accred with ID #{accred.id} should belong to a profile"
    end
  end

  test "should not allow hiding all accreds for a profile" do
    all_accreds.each do |accred|
      next if !accred.visible || accred.profile.accreds.where(visible: true).count > 1

      accred.visible = false
      assert_not accred.save, "Accred with ID #{accred.id} should not allow hiding all accreds for a profile"
    end
  end

  test "hidden? should return correct value" do
    all_accreds.each do |accred|
      expected_hidden = !accred.visible?
      assert_equal expected_hidden, accred.hidden?,
                   "Accred with ID #{accred.id} hidden? method should return #{expected_hidden}"
    end
  end

  test "hidden_addr? should return correct value" do
    all_accreds.each do |accred|
      expected_hidden_addr = !accred.visible_addr?
      assert_equal expected_hidden_addr, accred.hidden_addr?,
                   "Accred with ID #{accred.id} hidden_addr? method should return #{expected_hidden_addr}"
    end
  end

  test "for_sciper should return accreds ordered by order" do
    scipers = all_accreds.pluck(:sciper).uniq
    scipers.each do |sciper|
      accreds = Accred.for_sciper(sciper)
      assert_equal accreds.order(:order), accreds, "Accreds for sciper #{sciper} should be ordered by order"
    end
  end

  test "for_profile! should return accreditations prefs for profile" do
    profiles = Profile.all
    profiles.each do |profile|
      accreditations_prefs = Accred.for_profile!(profile)
      assert_not_empty accreditations_prefs, "Expected accreditation prefs for profile #{profile.id}"
    end
  end
end
