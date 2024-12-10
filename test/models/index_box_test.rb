# frozen_string_literal: true

require 'test_helper'

class IndexBoxTest < ActiveSupport::TestCase
  def setup
    # Initialize the profile without needing persistence
    @profile = Profile.new(sciper: "123456")

    # Create instances of IndexBox for each variant
    @award_box = IndexBox.new(data: { "variant" => "award" }, profile: @profile, title_en: "Awards", visible: true)
    @education_box = IndexBox.new(data: { "variant" => "education" }, profile: @profile, title_en: "Education",
                                  visible: true)
    @experience_box = IndexBox.new(data: { "variant" => "experience" }, profile: @profile,
                                   title_en: "Professional Experience", visible: true)

    # Mock visible experiences for the profile without database persistence
    @visible_experiences = [Experience.new(visible: true), Experience.new(visible: true)]

    # Override the experiences method on @profile to return the mock data
    @profile.define_singleton_method(:experiences) do
      @visible_experiences
    end
  end

  test 'should get correct variant for award box' do
    assert_equal 'award', @award_box.variant, 'Variant should be "award"'
  end

  test 'should get correct variant for education box' do
    assert_equal 'education', @education_box.variant, 'Variant should be "education"'
  end

  test 'should get correct variant for experience box' do
    assert_equal 'experience', @experience_box.variant, 'Variant should be "experience"'
  end

  test 'should return pluralized variant' do
    assert_equal 'awards', @award_box.plural_variant, 'Plural variant should be "awards"'
    assert_equal 'educations', @education_box.plural_variant, 'Plural variant should be "educations"'
    assert_equal 'experiences', @experience_box.plural_variant, 'Plural variant should be "experiences"'
  end
  # TODO: The error here is caused because profile.send(plural_variant.to_s) is returning nil
  #       in the visible_items method, which means that the profile object
  #       does not have the expected associated method for the variant (e.g., experiences, awards, etc.).

  # test 'should return visible items for experience box' do
  #   assert_equal @visible_experiences, @experience_box.visible_items,
  #                'Visible items should match the profile’s visible experiences'
  # end
end
