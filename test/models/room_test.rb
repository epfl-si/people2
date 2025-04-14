# frozen_string_literal: true

require "test_helper"

class RoomTest < ActiveSupport::TestCase
  setup do
    @room_data = {
      "id" => "123",
      "unitid" => "456",
      "name" => "CM1 123",
      "order" => "1",
      "hidden" => "0",
      "fromdefault" => "1"
    }
  end

  test "initialize sets correct attributes" do
    room = Room.new(@room_data)

    assert_equal 123, room.id
    assert_equal 456, room.unit_id
    assert_equal "CM1 123", room.name
    assert_equal 1, room.order
  end

  test "visible? returns true when not hidden" do
    room = Room.new(@room_data)
    assert room.visible?
  end

  test "hidden? returns false when not hidden" do
    room = Room.new(@room_data)
    assert_not room.hidden?
  end

  test "default? returns true when from_default is true" do
    room = Room.new(@room_data)
    assert room.default?
  end

  test "eql? returns true for rooms with same name" do
    room1 = Room.new(@room_data)
    room2 = Room.new(@room_data.merge("id" => "999"))

    assert room1.eql?(room2)
  end

  test "eql? returns false for rooms with different name" do
    room1 = Room.new(@room_data)
    room2 = Room.new(@room_data.merge("name" => "CO1 222"))

    assert_not room1.eql?(room2)
  end

  test "url returns a plan URL with the room name as query param" do
    room = Room.new(@room_data)
    expected_url = "https://plan.epfl.ch/?room=CM1+123"

    assert_equal expected_url, room.url.to_s
  end

  test "hidden? returns true when hidden is 1" do
    room_data = @room_data.merge("hidden" => "1")
    room = Room.new(room_data)

    assert room.hidden?
    assert_not room.visible?
  end

  test "default? returns false when fromdefault is 0" do
    room_data = @room_data.merge("fromdefault" => "0")
    room = Room.new(room_data)

    assert_not room.default?
  end
end
