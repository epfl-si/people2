# frozen_string_literal: true

require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  setup do
    fake_unit_data = {
      'id' => 1,
      'name' => 'EPFL',
      'nameen' => 'EPFL',
      'namede' => nil,
      'nameid' => nil,
      'labelfr' => 'École Polytechnique Fédérale de Lausanne',
      'labelen' => nil,
      'labelde' => nil,
      'labelid' => nil,
      'type' => 'University',
      'responsibleid' => nil,
      'url' => nil,
      'directchildren' => '2,3',
      'allchildren' => '2,3,4',
      'country' => 'Switzerland',
      'address1' => 'Route Cantonale',
      'address2' => nil,
      'address3' => nil,
      'address4' => nil,
      'city' => 'Lausanne',
      'path' => 'EPFL'
    }

    @original_api_unit_getter = APIUnitGetter.method(:call)

    APIUnitGetter.define_singleton_method(:call) do |id:, **_kwargs|
      if [1, "EPFL"].include?(id)
        fake_unit_data
      elsif [2, 3, 4].include?(id)
        {
          'id' => id,
          'name' => "Child#{id}",
          'nameen' => "Child#{id}",
          'namede' => nil,
          'nameid' => nil,
          'labelfr' => "Child#{id} FR",
          'labelen' => "Child#{id} EN",
          'labelde' => nil,
          'labelid' => nil,
          'type' => 'Faculty',
          'responsibleid' => nil,
          'url' => nil,
          'directchildren' => '',
          'allchildren' => '',
          'country' => 'Switzerland',
          'address1' => 'Rue de l\'Enfance',
          'address2' => nil,
          'address3' => nil,
          'address4' => nil,
          'city' => 'Lausanne',
          'path' => 'EPFL Faculty'
        }
      end
    end
  end

  teardown do
    APIUnitGetter.define_singleton_method(:call, @original_api_unit_getter)
  end

  test "find returns a Unit with correct attributes" do
    unit = Unit.find(1)
    assert_equal 1, unit.instance_variable_get(:@id)
    assert_equal 'EPFL', unit.instance_variable_get(:@name_fr)
    assert_equal 'École Polytechnique Fédérale de Lausanne', unit.instance_variable_get(:@label_fr)
    assert_equal 'University', unit.instance_variable_get(:@kind)
  end

  test "find_by returns a Unit by name" do
    unit = Unit.find_by(name: "EPFL")
    assert_not_nil unit
    assert_equal 1, unit.instance_variable_get(:@id)
  end

  test "parent returns the parent Unit" do
    unit = Unit.find(1)
    assert_nil unit.instance_variable_get(:@parent_id)
  end

  test "direct_children returns correct Units" do
    unit = Unit.find(1)
    children = unit.direct_children
    assert_equal([2, 3], children.map { |child| child.instance_variable_get(:@id) })
  end

  test "all_children returns correct Units" do
    unit = Unit.find(1)
    all_children = unit.all_children
    assert_equal([2, 3, 4], all_children.map { |child| child.instance_variable_get(:@id) })
  end
end
