# frozen_string_literal: true

require "test_helper"

class FunctionChangeMailerTest < ActionMailer::TestCase
  test "accreditor_request" do
    mail = FunctionChangeMailer.accreditor_request
    assert_equal "Accreditor request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
