# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'
require 'ostruct'

class PersonTest < ActiveSupport::TestCase
  def setup
    @person_data = {
      'id' => '123456',
      'firstname' => 'John',
      'lastname' => 'Doe',
      'firstnameusual' => 'Johnny',
      'lastnameusual' => 'Doe',
      'position' => { 'title' => 'Professor' },
      'phones' => [
        { 'unit_id' => '101', 'number' => '12345', 'visible' => true },
        { 'unit_id' => '101', 'number' => '1234123132', 'visible' => false }
      ],
      'addresses' => [
        { 'unitid' => '101', 'part1' => 'Office', 'part2' => 'EPFL', 'fromdefault' => '1' }
      ],
      'account' => { 'sciper' => '123456' },
      'automap' => { 'field1' => 'value1' },
      'camipro' => { 'card_number' => '1234' },
      'email' => 'john.doe@epfl.ch'
    }

    @person = Person.send(:new, @person_data)
  end

  # Test de l'initialisation
  test "should initialize person with correct data" do
    assert_equal '123456', @person.sciper
    assert_equal 'Johnny', @person.name.usual_first
    assert_equal 'Doe', @person.name.usual_last
    assert @person.position.is_a?(Position), "Position should be initialized as a Position object"
  end

  # Test de la méthode find avec stub
  test "should find a person by sciper" do
    api_person_data = @person_data.merge('firstname' => 'John')
    APIPersonGetter.stub :for_sciper, OpenStruct.new(fetch!: api_person_data) do
      person = Person.find(123_456)
      assert_equal 'John', person.name.official_first
    end
  end

  # Test du profil avec stub
  test "should fetch or create profile" do
    Profile.stub :for_sciper, Profile.new(sciper: '123456') do
      profile = @person.profile!
      assert_equal '123456', profile.sciper
    end
  end

  # Test des adresses pour une unité donnée
  test "should return addresses for a given unit" do
    address_data = [Address.new({ 'unitid' => '101', 'part1' => 'Office', 'part2' => 'EPFL', 'fromdefault' => '1' })]
    @person.instance_variable_set(:@addresses, { 101 => address_data })

    addresses = @person.addresses(101)
    assert_equal 1, addresses.count
    assert_equal 'Office', addresses.first.hierarchy
  end

  # Test des téléphones visibles
  test "should return visible phones for a given unit" do
    # Force l'association de téléphones visibles pour l'unité 101
    visible_phone_data = [Phone.new({ 'unit_id' => 101, 'number' => '12345', 'visible' => true })]
    @person.instance_variable_set(:@phones, { 101 => visible_phone_data })

    phones = @person.visible_phones(101)
    assert_equal 1, phones.count, "Should return only one visible phone."
    assert_equal '12345', phones.first.number
  end

  # Test de l'accréditation avec WebMock stub
  test "should return accreditations" do
    stub_request(:get, "https://api.epfl.ch/v1/authorizations?authid=gestprofil&persid=123456&status=active&type=property")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Basic BASE64USERPASS',
          'Host' => 'api.epfl.ch',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(
        status: 200,
        body: String.new('{
        "authorizations": [
          {
            "type": "property",
            "attribution": "default",
            "authid": 7,
            "persid": 348165,
            "resourceid": "13030",
            "accredunitid": 13030,
            "value": "y:U10000",
            "enddate": null,
            "status": "active",
            "workflowid": 0,
            "labelfr": "Éditer le profil People",
            "labelen": "Edit People profile",
            "name": "gestprofil",
            "reasontype": "unit",
            "reasonid": "10000",
            "reasonresourceid": "10000",
            "reasonname": "EPFL",
            "reasonlabelfr": "Ecole polytechnique fédérale de Lausanne",
            "reasonlabelen": "Ecole polytechnique fédérale de Lausanne"
          }
        ],
        "count": 1,
        "hidden": 0
      }'),
        headers: {}
      )

    mock_accreditation_data = {
      'persid' => '123456',
      'unit' => { 'id' => '101', 'name' => 'EPFL', 'labelfr' => 'Laboratoire' },
      'status' => { 'id' => '1', 'labelfr' => 'Actif' },
      'position' => { 'labelen' => 'Professor', 'labelfr' => 'Professeur' },
      'order' => 1
    }

    Accreditation.stub :for_sciper, [Accreditation.new(mock_accreditation_data)] do
      accreditations = @person.accreditations
      assert_not_nil accreditations, "Accreditations should not be nil"
      assert_equal 1, accreditations.size
    end
  end
end
