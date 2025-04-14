# frozen_string_literal: true

require 'test_helper'

class RichTextBoxTest < ActiveSupport::TestCase
  test "content? returns true if translated content is present" do
    box = RichTextBox.new
    box.define_singleton_method(:t_content) { |_primary, _fallback| "Some content" }

    assert box.content?
  end

  test "content? returns false if translated content is blank" do
    box = RichTextBox.new
    box.define_singleton_method(:t_content) { |_primary, _fallback| "" }

    assert_not box.content?
  end

  test "content_for? returns true if visible and has content" do
    box = RichTextBox.new
    box.define_singleton_method(:visible_by?) { |_level| true }
    box.define_singleton_method(:t_content) { |_primary, _fallback| "Visible content" }

    assert box.content_for?(0)
  end

  test "content_for? returns false if not visible" do
    box = RichTextBox.new
    box.define_singleton_method(:visible_by?) { |_level| false }
    box.define_singleton_method(:t_content) { |_primary, _fallback| "Content" }

    assert_not box.content_for?(0)
  end

  test "content_for? returns false if no content" do
    box = RichTextBox.new
    box.define_singleton_method(:visible_by?) { |_level| true }
    box.define_singleton_method(:t_content) { |_primary, _fallback| "" }

    assert_not box.content_for?(0)
  end
end
