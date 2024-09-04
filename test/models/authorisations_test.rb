# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class AuthorisationTest < ActiveSupport::TestCase
  def setup
    @auth_data1 = {
      'type' => 'Admin',
      'persid' => '12345',
      'resourceid' => '101',
      'value' => 'y123',
      'labelen' => 'Administrator',
      'label_fr' => 'Administrateur',
      'name' => 'John Doe'
    }

    @auth_data2 = {
      'type' => 'User',
      'persid' => '67890',
      'resourceid' => '102',
      'value' => 'n456',
      'labelen' => 'User',
      'label_fr' => 'Utilisateur',
      'name' => 'Jane Smith'
    }

    @auth1 = Authorisation.new(@auth_data1)
    @auth2 = Authorisation.new(@auth_data2)
  end

  test "should initialize with correct attributes" do
    assert_equal 'Admin', @auth1.type
    assert_equal '12345', @auth1.sciper
    assert_equal '101', @auth1.unit_id
    assert_equal 'y123', @auth1.instance_variable_get(:@value)
    assert_equal 'Administrator', @auth1.instance_variable_get(:@label_en)
    assert_equal 'Administrateur', @auth1.instance_variable_get(:@label_fr)
    assert_equal 'John Doe', @auth1.name

    assert_equal 'User', @auth2.type
    assert_equal '67890', @auth2.sciper
    assert_equal '102', @auth2.unit_id
    assert_equal 'n456', @auth2.instance_variable_get(:@value)
    assert_equal 'User', @auth2.instance_variable_get(:@label_en)
    assert_equal 'Utilisateur', @auth2.instance_variable_get(:@label_fr)
    assert_equal 'Jane Smith', @auth2.name
  end

  test "ok? should return true if value starts with 'y'" do
    assert @auth1.ok?, "Authorisation1 should return true for ok?"
    assert_not @auth2.ok?, "Authorisation2 should return false for ok?"
  end

  test "botweb_for_sciper should return authorisations for sciper" do
    mock = Minitest::Mock.new
    mock.expect :fetch, [@auth_data1]

    APIAuthGetter.stub :new, mock do
      auths = Authorisation.botweb_for_sciper('12345')
      assert_not_empty auths, "Expected non-empty authorisations list for sciper '12345'"
      assert_equal '12345', auths.first.sciper
      assert_equal '101', auths.first.unit_id
      assert_equal 'y123', auths.first.instance_variable_get(:@value)
    end

    mock.verify
  end

  # is used to simulate calls to APIAuthGetter.new.fetch,
  # we'll use Minitest::Mock to stub the fetch method to return controlled data during the test.
  test "right_for_sciper should return authorisations for a specific right" do
    mock = Minitest::Mock.new
    mock.expect :fetch, [@auth_data2]

    APIAuthGetter.stub :new, mock do
      auths = Authorisation.right_for_sciper('67890', 'AAR.report.control')
      assert_not_empty auths,
                       "Expected non-empty authorisations list for sciper '67890' with right 'AAR.report.control'"
      assert_equal '67890', auths.first.sciper
      assert_equal '102', auths.first.unit_id
      assert_equal 'n456', auths.first.instance_variable_get(:@value)
    end

    mock.verify
  end
end
