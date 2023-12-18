require "test_helper"

class CvTest < ActiveSupport::TestCase
  test "shy person does not provide his personal photo url" do
    u = cv(:edouard)
    assert_equal(false, u.show_photo)
    assert_nil(u.photo_url)
  end

  test "person with a picture but prefers the one from camipro to be visible" do
    u = cv(:natalie)
    assert_equal(true, u.show_photo)
    assert_equal(1, u.profile_pictures.count)
    assert_nil(u.selected_picture)
    assert_not_nil(u.photo_url)
    assert_match(/camipro-photos\.epfl\.ch/, u.photo_url)
  end

  test "person with several personal pictures one of which is the one to be shown" do
    u = cv(:giova)
    assert_equal(true, u.show_photo)
    assert_equal(2, u.profile_pictures.count)
    assert_not_nil(u.selected_picture)
    assert_not_nil(u.photo_url)
    assert_no_match(/camipro-photos\.epfl\.ch/, u.photo_url)
  end
end
