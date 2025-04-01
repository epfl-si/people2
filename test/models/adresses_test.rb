# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  # There is no addresses in the database so we can't use fixtures.
  test "initializes with correct attributes" do
    data = {
      "unitid" => "42",
      "type" => "work",
      "country" => "CH",
      "part1" => "EPFL",
      "part2" => "School of Engineering",
      "part3" => "IC",
      "part4" => "",
      "address" => "EPFL $ School of Engineering $ IC",
      "fromdefault" => "1"
    }

    address = Address.new(data)

    assert_equal 42, address.unit_id
    assert_equal "EPFL", address.hierarchy
    assert_equal ["EPFL", "School of Engineering", "IC"], address.lines
    assert_equal "EPFL $ School of Engineering $ IC", address.full
    assert address.default?, "Should be default since fromdefault is '1'"
  end

  test "default? returns false when fromdefault is 0" do
    address = Address.new({ "unitid" => "1", "fromdefault" => "0", "part1" => "A" })
    assert_not address.default?, "Should not be default"
  end

  test "eql? returns true when unit_id and lines match" do
    data1 = { "unitid" => "1", "part1" => "A", "fromdefault" => "0" }
    data2 = { "unitid" => "1", "part1" => "A", "fromdefault" => "0" }

    a1 = Address.new(data1)
    a2 = Address.new(data2)

    assert a1.eql?(a2), "Addresses with same unit_id and lines should be equal"
  end

  test "eql? returns false when unit_id or lines differ" do
    a1 = Address.new({ "unitid" => "1", "part1" => "A" })
    a2 = Address.new({ "unitid" => "2", "part1" => "A" })
    a3 = Address.new({ "unitid" => "1", "part1" => "B" })

    refute a1.eql?(a2), "Different unit_id should not be equal"
    refute a1.eql?(a3), "Different lines should not be equal"
  end
end
