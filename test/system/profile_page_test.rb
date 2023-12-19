# frozen_string_literal: true

require 'application_system_test_case'

class ProfilePageTest < ApplicationSystemTestCase
  # Olivier Lévêque
  test 'Olivier profile shows consistence data' do
    visit cv_url(sciper_or_name: '107931')
    assert_selector 'h1', text: 'Olivier Lévêque'
  end
  test 'visit Olivier profile shows his name' do
    visit cv_url(sciper_or_name: '121769')
    assert_selector 'h1', text: 'Giovanni Cangiani'
  end
end
