# frozen_string_literal: true

require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  test "delegates sciper to profile" do
    profile = Profile.new(sciper: "123456")
    award = Award.new(profile: profile)

    assert_equal "123456", award.sciper
  end

  test "award instance responds to selectable properties" do
    award = Award.new
    assert_respond_to award, :category
    assert_respond_to award, :origin
  end
end
