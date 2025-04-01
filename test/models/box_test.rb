# frozen_string_literal: true

require "test_helper"

class BoxTest < ActiveSupport::TestCase
  fixtures :boxes, :profiles, :sections, :model_boxes

  test "from_model builds a box with correct attributes" do
    model_box = model_boxes(:rich_text_model)

    box = Box.from_model(model_box, { subkind: "updated-subkind" })

    assert_equal model_box.section, box.section
    assert_equal model_box, box.model
    assert_equal model_box.kind, box.type
    assert_equal model_box.title_en, box.title_en
    assert_equal "updated-subkind", box.subkind
  end

  test "content? raises error in base Box class" do
    box = Box.new
    assert_raises RuntimeError, "The (abstract) 'content?' method needs to be implemented in the class" do
      box.content?
    end
  end

  test "delegates sciper to profile" do
    box = boxes(:basic_box)
    assert_equal "123456", box.sciper
  end
end
