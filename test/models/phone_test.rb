# frozen_string_literal: true

require "test_helper"

class PhoneTest < ActiveSupport::TestCase
  test "initializes with correct attributes" do
    data = { "unitid" => "42", "order" => "3", "number" => "+41 21 123 45 67", "hidden" => "0", "fromdefault" => "1" }
    phone = Phone.new(data)

    assert_equal 42, phone.unit_id
    assert_equal 3, phone.order
    assert_equal "+41 21 123 45 67", phone.number
    assert phone.default?
    assert phone.visible?
    refute phone.hidden?
  end

  test "hidden? is true when hidden is 1" do
    phone = Phone.new({ "hidden" => "1", "unitid" => "1", "order" => "0" })
    assert phone.hidden?
    refute phone.visible?
  end

  test "default? is false when fromdefault is 0" do
    phone = Phone.new({ "fromdefault" => "0", "unitid" => "1", "order" => "0" })
    refute phone.default?
  end

  test "phones are comparable by order" do
    p1 = Phone.new({ "unitid" => "1", "order" => "2" })
    p2 = Phone.new({ "unitid" => "1", "order" => "1" })

    assert_operator p2, :<, p1
    assert_equal [p2, p1], [p1, p2].sort
  end
end
