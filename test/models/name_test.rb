# frozen_string_literal: true

require "test_helper"

class NameTest < ActiveSupport::TestCase
  test "display_first falls back to official if usual is nil" do
    name = Name.new(official_first: "Jean-Pierre")
    assert_equal "Jean-Pierre", name.display_first
  end

  test "display_last falls back to official if usual is nil" do
    name = Name.new(official_last: "Dupont")
    assert_equal "Dupont", name.display_last
  end

  test "display uses usual names when available" do
    name = Name.new(
      official_first: "Jean-Pierre",
      official_last: "Dupont-Smith",
      usual_first: "Jean",
      usual_last: "Smith"
    )
    assert_equal "Jean Smith", name.display
  end

  test "suggested_first returns first part of official first name" do
    name = Name.new(official_first: "Jean-Pierre")
    assert_equal "Jean", name.suggested_first
  end

  test "customizable_first? is true if official first has multiple parts" do
    name = Name.new(official_first: "Jean Pierre")
    assert name.customizable_first?
  end

  test "customizable_last? is false if official last has one part" do
    name = Name.new(official_last: "Dupont")
    assert_not name.customizable_last?
  end

  test "usual_names_are_taken_from_official adds error when usual_first is not part of official" do
    name = Name.new(
      official_first: "Jean-Pierre",
      official_last: "Dupont",
      usual_first: "Luc"
    )
    name.valid?
    assert name.errors[:usual_first].any?, "Expected an error on :usual_first"
  end

  test "usual_names_are_taken_from_official accepts matching usual names" do
    name = Name.new(
      official_first: "Jean-Pierre",
      official_last: "Dupont",
      usual_first: "Jean"
    )
    name.valid?
    assert_empty name.errors[:usual_first]
  end
end
