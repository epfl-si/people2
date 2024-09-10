# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'shy person does not provide his personal photo' do
    u = profiles(:edouard)
    assert_not(u.show_photo)
    assert_nil(u.photo)
  end

  test 'person with one personal picture and no camipro picture' do
    u = profiles(:natalie)
    assert(u.show_photo)
    assert_equal(1, u.pictures.count)
    p = u.pictures.first
    assert_not p.camipro?, "The personal picture appears as the camipro one"
    u.cache_camipro_picture!
    assert_equal(2, u.pictures.count)
    assert_not_nil u.selected_picture, "Selected picture is absent"
  end

  test 'profile with no picture gets camipro picture by default' do
    u = profiles(:edouard)
    assert_equal(0, u.pictures.count)

    p = u.photo!
    assert_equal(1, u.pictures.count)
    assert p.camipro?
  end
end
