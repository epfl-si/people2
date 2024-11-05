# frozen_string_literal: true

require 'test_helper'

class PhoneTest < Minitest::Test
  def setup
    @phone_visible = Phone.new({
                                 'unitid' => '101',
                                 'order' => '1',
                                 'hidden' => '0',
                                 'number' => '12345',
                                 'fromdefault' => '1'
                               })

    @phone_hidden = Phone.new({
                                'unitid' => '102',
                                'order' => '2',
                                'hidden' => '1',
                                'number' => '67890',
                                'fromdefault' => '0'
                              })

    @phone_second = Phone.new({
                                'unitid' => '101',
                                'order' => '2',
                                'hidden' => '0',
                                'number' => '54321',
                                'fromdefault' => '0'
                              })
  end

  def test_initialization
    assert_equal 101, @phone_visible.unit_id
    assert_equal 1, @phone_visible.order
    assert_equal '12345', @phone_visible.number
    assert @phone_visible.default?, "Phone should be marked as default"
  end

  def test_visibility
    assert @phone_visible.visible?, "Phone should be visible"
    refute @phone_hidden.visible?, "Phone should be hidden"
  end

  def test_hidden
    refute @phone_visible.hidden?, "Phone should not be hidden"
    assert @phone_hidden.hidden?, "Phone should be hidden"
  end

  def test_default
    assert @phone_visible.default?, "Phone should be marked as default"
    refute @phone_hidden.default?, "Phone should not be marked as default"
  end

  def test_comparison_operator
    assert @phone_visible < @phone_second, "Phone with order 1 should come before phone with order 2"
    assert @phone_second > @phone_visible, "Phone with order 2 should come after phone with order 1"
  end

  def test_number
    assert_equal '12345', @phone_visible.number
    assert_equal '67890', @phone_hidden.number
  end
end
