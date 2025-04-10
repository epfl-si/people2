# frozen_string_literal: true

require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "initialize sets attributes correctly" do
    data = {
      "id" => 1,
      "name" => "Test Group",
      "description" => "A sample group",
      "gid" => 1001
    }

    group = Group.new(data)

    assert_equal 1, group.id
    assert_equal "Test Group", group.name
    assert_equal "A sample group", group.description
    assert_equal 1001, group.gid
  end

  test "find returns a Group object" do
    stubbed_data = {
      "id" => 2,
      "name" => "Stub Group",
      "description" => "Stubbed description",
      "gid" => 2002
    }

    original_method = APIGroupGetter.method(:call)
    APIGroupGetter.define_singleton_method(:call) do |**|
      stubbed_data
    end

    group = Group.find(2)
    assert_instance_of Group, group
    assert_equal 2, group.id
    assert_equal "Stub Group", group.name
  ensure
    APIGroupGetter.define_singleton_method(:call, original_method)
  end

  test "find raises error if id is invalid" do
    assert_raises RuntimeError, "Invalid id 0" do
      Group.find(0)
    end
  end

  test "find_by returns a Group object" do
    stubbed_data = {
      "id" => 3,
      "name" => "Another Group",
      "description" => "Another description",
      "gid" => 3003
    }

    original_method = APIGroupGetter.method(:call)
    APIGroupGetter.define_singleton_method(:call) do |**|
      stubbed_data
    end

    group = Group.find_by(name: "valid_name", force: true)
    assert_instance_of Group, group
    assert_equal "Another Group", group.name
    assert_equal 3003, group.gid
  ensure
    APIGroupGetter.define_singleton_method(:call, original_method)
  end

  test "find_by raises error if name is invalid" do
    assert_raises RuntimeError, "Invalid name invalid name" do
      Group.find_by(name: "invalid name")
    end
  end
end
