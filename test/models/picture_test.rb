# frozen_string_literal: true

require "test_helper"
require "stringio"

class PictureTest < ActiveSupport::TestCase
  test "selected? returns true if picture id matches profile" do
    picture = Picture.new(id: 42)
    profile = OpenStruct.new(selected_picture_id: 42)
    picture.define_singleton_method(:profile) { profile }

    assert picture.selected?
  end

  test "visible_image returns cropped image if attached" do
    picture = Picture.new

    cropped = Object.new
    def cropped.attached? = true

    picture.define_singleton_method(:cropped_image) { cropped }
    picture.define_singleton_method(:image) { raise "should not be called" }

    assert_equal cropped, picture.visible_image
  end

  test "visible_image returns image if cropped not attached" do
    picture = Picture.new

    cropped = Object.new
    def cropped.attached? = false

    image = Object.new
    def image.attached? = true

    picture.define_singleton_method(:cropped_image) { cropped }
    picture.define_singleton_method(:image) { image }

    assert_equal image, picture.visible_image
  end

  test "refuse_destroy_if_camipro prevents deletion unless destroyed by association" do
    picture = Picture.new(camipro: true)
    picture.define_singleton_method(:destroyed_by_association) { nil }

    result = picture.run_callbacks(:destroy) { true }

    refute result
    assert_includes picture.errors[:base], "activerecord.errors.picture.attributes.base.undeletable"
  end

  test "fetch schedules job if below max attempts" do
    picture = Picture.new(camipro: true)
    picture.failed_attempts = 1
    picture.define_singleton_method(:id) { 42 }

    original_method = CamiproPictureCacheJob.method(:perform_later)
    job_called = false

    CamiproPictureCacheJob.define_singleton_method(:perform_later) do |id|
      job_called = (id == 42)
    end

    picture.fetch

    assert job_called, "Expected job to be scheduled"
  ensure
    CamiproPictureCacheJob.define_singleton_method(:perform_later, original_method)
  end

  test "fetch! attaches camipro image using correct URL" do
    picture = Picture.new(id: 42, camipro: true)
    profile = OpenStruct.new(sciper: "123456")
    picture.define_singleton_method(:profile) { profile }

    fake_io = StringIO.new("fake image data")
    fake_url = Object.new
    fake_url.define_singleton_method(:open) { fake_io }

    original_camipro_url = Picture.method(:camipro_url)
    original_uri_parse = URI.method(:parse)

    Picture.define_singleton_method(:camipro_url) { |_sciper| "http://stub.url/image.jpg" }
    URI.define_singleton_method(:parse) { |_url| fake_url }

    image_mock = Object.new
    attached = false
    image_mock.define_singleton_method(:attach) do |args|
      attached = args[:io] == fake_io && args[:filename] == "123456.jpg"
    end
    picture.define_singleton_method(:image) { image_mock }

    picture.fetch!

    assert attached, "Expected image to be attached from fake IO"
  ensure
    Picture.define_singleton_method(:camipro_url, original_camipro_url)
    URI.define_singleton_method(:parse, original_uri_parse)
  end
end
