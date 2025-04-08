# frozen_string_literal: true

require 'test_helper'

class SpecialMailTest < ActiveSupport::TestCase
  test "for_sciper_or_name returns only the first match" do
    SpecialMail.create!(sciper: 123_456, data: "email1@epfl.ch")
    SpecialMail.create!(sciper: 123_456, data: "email2@epfl.ch")

    result = SpecialMail.for_sciper_or_name("123456")
    assert_equal "email1@epfl.ch", result.email
  end

  test "email returns the data string" do
    mail = SpecialMail.new(data: "test@epfl.ch")
    assert_equal "test@epfl.ch", mail.email
  end
end
