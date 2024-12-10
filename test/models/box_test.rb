# frozen_string_literal: true

require 'test_helper'

class BoxTest < ActiveSupport::TestCase
  fixtures :boxes, :sections, :profiles

  def setup
    @gio_box_expertise = boxes(:gio_box_expertise)
    @gio_box_education = boxes(:gio_box_education)
    @edo_box_awards = boxes(:edo_box_awards)
    @nat_box_expertise = boxes(:nat_box_expertise)
    @nat_box_cv = boxes(:nat_box_cv)
  end

  # Test des attributs de base
  test "should have correct attributes" do
    assert_equal "Expertise", @gio_box_expertise.title_en
    assert_equal "Domaines de compétences", @gio_box_expertise.title_fr
    assert @gio_box_expertise.show_title
    assert @gio_box_expertise.locked
    assert @gio_box_expertise.visible
    assert_equal 0, @gio_box_expertise.audience
    assert_equal 1, @gio_box_expertise.position
  end

  test "should belong to section and profile" do
    assert_equal sections(:bio), @gio_box_expertise.section
    assert_equal profiles(:giova), @gio_box_expertise.profile
  end

  test "from_model should initialize a new Box from a model box" do
    model_box = Box.new(
      section_id: sections(:bio).id,
      title_en: "New Model Box Title",
      title_fr: "Nouveau titre de boîte modèle",
      show_title: true,
      locked: false,
      position: 4
    )

    new_box = Box.from_model(model_box)

    assert_equal model_box.section_id, new_box.section_id
    assert_equal model_box.title_en, new_box.title_en
    assert_equal model_box.title_fr, new_box.title_fr
    assert new_box.locked, "New box should be locked"
    assert_equal model_box.position, new_box.position
  end

  test "content? should return true by default" do
    assert @gio_box_expertise.content?
    assert @gio_box_education.content?
  end

  test "should delegate sciper to profile" do
    assert_equal @gio_box_expertise.profile.sciper, @gio_box_expertise.sciper
  end

  test "should correctly identify visible and hidden boxes" do
    assert @gio_box_expertise.visible
    assert_not @nat_box_expertise.visible
  end

  test "should filter boxes by audience correctly" do
    intranet_boxes = Box.where(audience: 1)
    assert_includes intranet_boxes, boxes(:nat_box_work), "nat_box_work should be visible only on intranet"
    assert_not_includes intranet_boxes, boxes(:gio_box_expertise), "gio_box_expertise should not be limited to intranet"
  end

  # Single Table Inheritance (STI) → TODO, uncomment when using this method
  # test "should correctly identify STI subclasses" do
  # assert @gio_box_expertise.is_a?(RichTextBox), "Expected @gio_box_expertise to be a RichTextBox"
  # assert @gio_box_education.is_a?(IndexBox), "Expected @gio_box_education to be a IndexBox"
  # end
end
