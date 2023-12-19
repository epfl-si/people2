# frozen_string_literal: true

require 'application_system_test_case'

class LegacyViewsTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit legacy_views_url
  #
  #   assert_selector "h1", text: "LegacyViews"
  # end
  test 'visit a person with a single accreditation and no teaching' do
    visit person_url(sciper_or_name: '121769')
    assert_selector 'h1', text: 'Giovanni Cangiani'
  end
end
