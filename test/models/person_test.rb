# frozen_string_literal: true

require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  def minimal_person_data(overrides = {})
    {
      "id" => "123456",
      "firstname" => "Jean-Claude",
      "lastname" => "Dupont",
      "email" => "jean.dupont@epfl.ch",
      "account" => { "username" => "jdupont" },
      "automap" => {},
      "camipro" => {}
    }.merge(overrides)
  end

  test "email_user returns the local part of email" do
    person = Person.send(:new, minimal_person_data)
    assert_equal "jean.dupont", person.email_user
  end

  test "admin_data merges account, automap, camipro and sciper" do
    data = minimal_person_data("account" => { "username" => "jdupont" })
    person = Person.send(:new, data)

    person.define_singleton_method(:sciper) { "123456" }

    admin = person.admin_data
    assert_equal "jdupont", admin.username
    assert_equal "123456", admin.sciper
  end

  test "display name from Name is built correctly" do
    person = Person.send(:new, minimal_person_data("firstnameusual" => "Jean", "lastnameusual" => "Dupond"))
    assert_equal "Jean Dupond", person.name.display
  end

  test "phones(unit_id) returns only phones for that unit" do
    phone_data = [
      { "number" => "111", "unitid" => 1 },
      { "number" => "222", "unitid" => 2 }
    ]

    person = Person.send(:new, minimal_person_data("phones" => phone_data))
    phones_for_unit_one = person.phones(1)
    assert_equal ["111"], phones_for_unit_one.map(&:number)
  end

  test "addresses(unit_id) returns only addresses for that unit" do
    address_data = [
      { "unitid" => 1, "part1" => "A" },
      { "unitid" => 2, "part1" => "B" }
    ]

    person = Person.send(:new, minimal_person_data("addresses" => address_data))
    addresses_for_unit_two = person.addresses(2)
    assert_equal ["B"], addresses_for_unit_two.map(&:hierarchy)
  end

  test "method_missing fetches value from raw data" do
    person = Person.send(:new, minimal_person_data("custom_field" => "value"))
    assert_equal "value", person.custom_field
  end

  test "respond_to_missing? returns true for data key" do
    person = Person.send(:new, minimal_person_data("custom_field" => "value"))
    assert_respond_to person, :custom_field
  end
end
