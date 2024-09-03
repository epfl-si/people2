# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  def setup
    @address_data1 = {
      'unitid' => '101',
      'type' => 'Office',
      'country' => 'CH',
      'part1' => 'Bâtiment A',
      'part2' => 'Etage 2',
      'part3' => 'Bureau 201',
      'part4' => 'Rue de l\'Exemple',
      'fromdefault' => '1'
    }

    @address_data2 = {
      'unitid' => '202',
      'type' => 'Home',
      'country' => 'FR',
      'part1' => 'Maison B',
      'part2' => 'Etage 1',
      'part3' => 'Appartment 10',
      'part4' => 'Avenue du Test',
      'fromdefault' => '0'
    }

    @incomplete_address_data = {
      'unitid' => '303',
      'type' => 'Warehouse',
      'country' => 'US',
      'part1' => 'Building C',
      'part2' => nil,
      'part3' => 'Suite 5',
      'part4' => nil,
      'fromdefault' => '1'
    }

    @address1 = Address.new(@address_data1)
    @address2 = Address.new(@address_data2)
    @incomplete_address = Address.new(@incomplete_address_data)
  end

  test "should initialize with correct attributes" do
    assert_equal 101, @address1.unit_id
    assert_equal 'Bâtiment A', @address1.hierarchy
    assert_equal ['Etage 2', 'Bureau 201', 'Rue de l\'Exemple'], @address1.lines
    assert @address1.default?

    assert_equal 202, @address2.unit_id
    assert_equal 'Maison B', @address2.hierarchy
    assert_equal ['Etage 1', 'Appartment 10', 'Avenue du Test'], @address2.lines
    assert_not @address2.default?
  end

  test "default? should return correct boolean value" do
    assert @address1.default?, "Address1 should be default"
    assert_not @address2.default?, "Address2 should not be default"
  end

  test "full should return a string with all address lines joined by ' $ '" do
    expected_full1 = "Etage 2 $ Bureau 201 $ Rue de l'Exemple"
    expected_full2 = "Etage 1 $ Appartment 10 $ Avenue du Test"

    assert_equal expected_full1, @address1.full, "Full address for Address1 is incorrect"
    assert_equal expected_full2, @address2.full, "Full address for Address2 is incorrect"
  end

  test "full should not have consecutive '$' symbols if some lines are missing" do
    expected_full_incomplete = "Suite 5"

    assert_equal expected_full_incomplete, @incomplete_address.full, "Full address for incomplete address should not have consecutive '$'"
  end
end
