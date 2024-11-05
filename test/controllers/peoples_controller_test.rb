# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @person_data = {
      'id' => '110635',
      'firstname' => 'Giovanni',
      'lastname' => 'Rossi',
      'firstnameusual' => 'Gio',
      'lastnameusual' => 'Rossi',
      'position' => { 'title' => 'Professor' },
      'gender' => 'male', # Added gender
      'phones' => [
        { 'unit_id' => '101', 'number' => '12345', 'visible' => true },
        { 'unit_id' => '101', 'number' => '67890', 'visible' => false }
      ],
      'addresses' => [
        { 'unitid' => '101', 'part1' => 'Office', 'part2' => 'EPFL', 'fromdefault' => '1' }
      ],
      'account' => { 'sciper' => '110635' },
      'automap' => { 'field1' => 'value1' },
      'camipro' => { 'card_number' => '1234' },
      'email' => 'giovanni.rossi@epfl.ch'
    }

    @accreditations_data = {
      'accreds' => [
        {
          'id' => '1',
          'label' => 'Professeur',
          'visible' => true,
          'unit' => { 'id' => 101, 'name' => 'EPFL', 'labelfr' => 'Lab' },
          'status' => { 'id' => 1, 'labelfr' => 'Actif' },
          'position' => { 'labelen' => 'Professor', 'labelfr' => 'Professeur' },
          'role' => 'Professor' # Ensure role is always present
        }
      ]
    }

    # Stub for persons API
    stub_request(:get, "https://api.epfl.ch/v1/persons/110635")
      .to_return(status: 200, body: @person_data.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    # Stub for accreditations API
    stub_request(:get, "https://api.epfl.ch/v1/accreds?persid=110635")
      .to_return(status: 200, body: @accreditations_data.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    # Stub for authorization API
    stub_request(:get, "https://api.epfl.ch/v1/authorizations?authid=botweb&persid=110635&status=active&type=property")
      .to_return(status: 200, body: { "authorizations" => [{ "unit_id" => 101,
                                                             "authorized" => true }] }.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    # Stub for units API
    stub_request(:get, "https://api.epfl.ch/v1/units/101")
      .to_return(status: 200, body: { 'name' => 'EPFL Unit',
                                      'labelfr' => 'Laboratoire' }.to_json,
                 headers: { 'Content-Type' => 'application/json' })

    @visible_accreditation = OpenStruct.new(visible?: true, label: 'Professeur', role: 'Professor',
                                            prefs: OpenStruct.new(visible?: true))
  end

  # test "should show person profile with correct title if profile is visible" do
  #   Accreditation.stub(:for_sciper, [@visible_accreditation]) do
  #     get person_url(sciper_or_name: '110635')
  #     assert_response :success
  #     assert_select 'title', "EPFL - #{@person_data['firstnameusual']} #{@person_data['lastname']}"
  #   end
  # end

  # test "should return 404 if no visible accreditations" do
  #   Accreditation.stub(:for_sciper, []) do
  #     get person_url(sciper_or_name: '110635')
  #     assert_response :not_found
  #   end
  # end

  # test "should show courses grouped by title for a person" do
  #   Isa::Teaching.stub(:new, OpenStruct.new(phd: [OpenStruct.new(current?: true, past?: false)])) do
  #     get person_url(sciper_or_name: '110635')
  #     assert_response :success
  #     assert_not_nil assigns(:courses), "Courses should be assigned based on profile data"
  #   end
  # end
end
