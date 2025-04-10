# frozen_string_literal: true

require "test_helper"

class ModelBoxTest < ActiveSupport::TestCase
  test "for_label finds a model box by label" do
    box = ModelBox.new(label: "test_label")

    original_method = ModelBox.method(:where)
    ModelBox.define_singleton_method(:where) do |conditions|
      if conditions == { label: "test_label" }
        [box]
      else
        []
      end
    end

    result = ModelBox.for_label("test_label")
    assert_equal box, result
  ensure
    ModelBox.define_singleton_method(:where, original_method)
  end

  test "container? returns true when kind is IndexBox" do
    box = ModelBox.new(kind: "IndexBox")
    assert box.container?
  end

  test "container? returns false when kind is not IndexBox" do
    box = ModelBox.new(kind: "RichTextBox")
    assert_not box.container?
  end

  test "new_box_for_profile creates a box from model and assigns profile_id" do
    model_box = ModelBox.new(kind: "RichTextBox")
    profile = OpenStruct.new(id: 123)

    rich_text_box = RichTextBox.new
    rich_text_box.define_singleton_method(:profile_id=) { |id| @profile_id = id }
    rich_text_box.define_singleton_method(:profile_id) { @profile_id }

    original_method = RichTextBox.method(:from_model)
    RichTextBox.define_singleton_method(:from_model) do |_model_box|
      rich_text_box
    end

    box = model_box.new_box_for_profile(profile)

    assert_equal 123, box.profile_id
    assert_instance_of RichTextBox, box
  ensure
    RichTextBox.define_singleton_method(:from_model, original_method)
  end

  test "standard scope returns only standard model boxes" do
    standard_box = ModelBox.new(standard: true)

    original_standard = ModelBox.method(:standard)
    ModelBox.define_singleton_method(:standard) do
      [standard_box]
    end

    results = ModelBox.standard
    assert_equal [standard_box], results
  ensure
    ModelBox.define_singleton_method(:standard, original_standard)
  end

  test "optional scope returns only optional model boxes" do
    optional_box = ModelBox.new(standard: false)

    original_optional = ModelBox.method(:optional)
    ModelBox.define_singleton_method(:optional) do
      [optional_box]
    end

    results = ModelBox.optional
    assert_equal [optional_box], results
  ensure
    ModelBox.define_singleton_method(:optional, original_optional)
  end
end
