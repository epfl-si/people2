# frozen_string_literal: true

require "test_helper"

class NamesControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get names_update_url
    assert_response :success
  end
end
