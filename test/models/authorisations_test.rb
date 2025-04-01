# frozen_string_literal: true

require 'test_helper'

class AuthorisationTest < ActiveSupport::TestCase
  test "initializes correctly and responds to ok? and active?" do
    data = {
      "type" => "property",
      "persid" => "123456",
      "resourceid" => "UNIT42",
      "value" => "yes",
      "status" => true,
      "labelen" => "Authorized",
      "label_fr" => "Autorisé",
      "name" => "Jane Doe"
    }

    auth = Authorisation.new(data)

    assert_equal "123456", auth.sciper
    assert_equal "UNIT42", auth.unit_id
    assert auth.ok?, "Expected ok? to be true"
    assert auth.active?, "Expected active? to be true"
  end

  test "ok? returns false when value does not start with 'y'" do
    data = {
      "type" => "property",
      "persid" => "123456",
      "resourceid" => "UNIT99",
      "value" => "no",
      "status" => false,
      "labelen" => "Not Authorized",
      "label_fr" => "Non autorisé",
      "name" => "Jane Doe"
    }

    auth = Authorisation.new(data)

    assert_not auth.ok?, "Expected ok? to be false"
    assert_not auth.active?, "Expected active? to be false"
  end
end
