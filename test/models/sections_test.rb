# frozen_string_literal: true

require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  test "content? returns true if at least one visible box has content" do
    section = Section.new

    box_with_content = Object.new
    box_with_content.define_singleton_method(:visible?) { true }
    box_with_content.define_singleton_method(:content?) { |_locale| true }

    box_without_content = Object.new
    box_without_content.define_singleton_method(:visible?) { true }
    box_without_content.define_singleton_method(:content?) { |_locale| false }

    section.define_singleton_method(:boxes) { [box_without_content, box_with_content] }

    assert section.content?
  end

  test "content? returns false if no boxes have content" do
    section = Section.new

    empty_box = Object.new
    empty_box.define_singleton_method(:visible?) { true }
    empty_box.define_singleton_method(:content?) { |_locale| false }

    hidden_box = Object.new
    hidden_box.define_singleton_method(:visible?) { false }
    hidden_box.define_singleton_method(:content?) { |_locale| true }

    section.define_singleton_method(:boxes) { [empty_box, hidden_box] }

    assert_not section.content?
  end

  test "content? returns false if no boxes are present" do
    section = Section.new
    section.define_singleton_method(:boxes) { [] }

    assert_not section.content?
  end
end
