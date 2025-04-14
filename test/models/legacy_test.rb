# frozen_string_literal: true

require "test_helper"

class LegacyTest < ActiveSupport::TestCase
  test "deshit returns same text if not a String" do
    assert_equal 123, Legacy.deshit(123)
    assert_nil Legacy.deshit(nil)
  end

  test "deshit cleans repeated <br> and &nbsp;" do
    dirty_text = "Hello<br><br>&nbsp;&nbsp;World<br>"
    expected_clean = "Hello<br>World"
    assert_equal expected_clean, Legacy.deshit(dirty_text)
  end

  test "deshit replaces special characters according to SHITMAP" do
    dirty_text = "FranÃ§ois Ã©tait lÃ ."
    expected_clean = "François était là."
    assert_equal expected_clean, Legacy.deshit(dirty_text)
  end

  test "deshit removes <div> tags" do
    dirty_text = "<div>Hello</div><div>World</div>"
    expected_clean = "HelloWorld"
    assert_equal expected_clean, Legacy.deshit(dirty_text)
  end

  class FakeBaseCv
    attr_accessor :description

    def initialize(description = nil)
      @description = description
    end

    def sanitized_description
      Legacy.deshit(@description)
    end
  end

  test "Legacy::BaseCv readonly is true" do
    # Not really usefull because it's not a real activeRecord but why not ?
    fake_base = Legacy::BaseCv.allocate
    assert_predicate fake_base, :readonly?
  end

  test "Legacy::BaseCv sanitized methods deshit the string" do
    fake_base = FakeBaseCv.new("FranÃ§ois")
    assert_equal "François", fake_base.sanitized_description
  end

  test "Legacy::BaseCv missing sanitized method raises NoMethodError if base method missing" do
    fake_base = FakeBaseCv.new
    assert_raises(NoMethodError) { fake_base.sanitized_nonexistent }
  end
end
