# frozen_string_literal: true

require 'test_helper'

class RedirectTest < ActiveSupport::TestCase
  def setup
    @redirect_sciper = redirects(:one)
    @redirect_ns = redirects(:one)
  end

  test 'should find redirect by sciper' do
    result = Redirect.for_sciper_or_name(123_456)
    assert_equal @redirect_sciper, result, 'The redirect should be found by sciper'
  end

  test 'should find redirect by name' do
    result = Redirect.for_sciper_or_name('ciccio.pasticcio')
    assert_equal @redirect_ns, result, 'The redirect should be found by name (ns)'
  end

  test 'should return nil for non-existing sciper' do
    result = Redirect.for_sciper_or_name(999_999)
    assert_nil result, 'The result should be nil for a non-existing sciper'
  end

  test 'should return nil for non-existing name' do
    result = Redirect.for_sciper_or_name('non.existing.name')
    assert_nil result, 'The result should be nil for a non-existing name (ns)'
  end

  test 'should return nil for malformed sciper' do
    result = Redirect.for_sciper_or_name('not-a-number')
    assert_nil result, 'The result should be nil for a malformed sciper input'
  end
end
