# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class PictureTest < ActiveSupport::TestCase
  test 'should generate the correct camipro URL' do
    sciper = '123456'
    expected_url_pattern = %r{https://.*/api/v1/photos/#{sciper}\?time=.*&app=people&hash=.*}

    url = Picture.camipro_url(sciper)
    assert_match expected_url_pattern, url, "Camipro URL doesn't match the expected pattern"
  end

  test 'should attach image when fetching camipro picture' do
    picture = pictures(:camipro_picture)
    profile = profiles(:natalie)
    sciper = profile.sciper

    stub_request(:get, "http://example.com/#{sciper}.jpg")
      .to_return(body: "image data", status: 200)

    Picture.stub :camipro_url, "http://example.com/#{sciper}.jpg" do
      picture.fetch!
    end

    assert picture.image.attached?, 'The image should be attached after fetching camipro picture'
  end

  test 'should schedule CamiproPictureCacheJob when fetch is called' do
    picture = pictures(:camipro_picture)
    picture.update(failed_attempts: 2)

    CamiproPictureCacheJob.stub :perform_later, true do
      picture.fetch
    end
  end

  test 'should not destroy camipro picture' do
    picture = pictures(:camipro_picture)
    picture.destroy

    assert_not picture.destroyed?, 'Camipro picture should not be destroyed'
    assert_includes picture.errors[:base], "activerecord.errors.picture.attributes.base.undeletable"
  end

  test 'should fetch camipro image if image is blank' do
    picture = pictures(:camipro_picture)
    picture.image.purge

    picture.stub :fetch, true do
      picture.check_attachment
    end
  end
end
