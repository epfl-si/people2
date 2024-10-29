# frozen_string_literal: true

require 'test_helper'

class SocialTest < ActiveSupport::TestCase
  def setup
    @linkedin_social = socials(:gio_social_linkedin)
    @linkedin_social.update(sciper: '121769')
    @github_social = socials(:gio_social_github)
    I18n.locale = :en
  end

  test 'should not save social without value' do
    @linkedin_social.value = nil
    refute @linkedin_social.valid?, 'Social without a value should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.value.blank')
    assert_includes @linkedin_social.errors[:value], error_message
  end

  test 'should not save social without tag' do
    @linkedin_social.tag = nil
    refute @linkedin_social.valid?, 'Social without a tag should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.tag.blank')
    assert_includes @linkedin_social.errors[:tag], error_message
  end

  test 'should not save social with invalid tag' do
    @linkedin_social.tag = 'invalid_tag'
    refute @linkedin_social.valid?, 'Social with invalid tag should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.tag.invalid')
    assert_includes @linkedin_social.errors[:tag], error_message
  end

  test 'should not save social with invalid value format' do
    @linkedin_social.value = 'invalid*format'
    refute @linkedin_social.valid?, 'Social with invalid value format should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.value.incorrect_format')
    assert_includes @linkedin_social.errors[:value], error_message
  end

  test 'should save valid social for LinkedIn' do
    assert @linkedin_social.valid?, 'Valid LinkedIn social should be saved'
  end

  test 'should save valid social for GitHub' do
    assert @github_social.valid?, 'Valid GitHub social should be saved'
  end

  test 'should generate correct LinkedIn URL' do
    expected_url = 'https://www.linkedin.com/in/giovannicangiani'
    assert_equal expected_url, @linkedin_social.url, 'URL should match LinkedIn format'
  end

  test 'should generate correct GitHub URL' do
    expected_url = 'https://github.com/multiscan'
    assert_equal expected_url, @github_social.url, 'URL should match GitHub format'
  end

  test 'should generate correct icon class for LinkedIn' do
    assert_equal 'social-icon-linkedin', @linkedin_social.icon_class, 'Icon class should match LinkedIn format'
  end

  test 'should return correct label for LinkedIn' do
    assert_equal 'Linkedin ID', @linkedin_social.label, 'Label should be "Linkedin ID" for LinkedIn social'
  end

  test 'should return correct default position for LinkedIn' do
    assert_equal 4, @linkedin_social.default_position, 'Default position for LinkedIn should be 4'
  end

  test 'should return correct image path for LinkedIn' do
    assert_equal 'social/linkedin.jpg', @linkedin_social.image, 'Image path should match LinkedIn format'
  end

  test 'should return correct URL prefix for LinkedIn' do
    assert_equal 'https://www.linkedin.com/in/', @linkedin_social.url_prefix, 'URL prefix should match LinkedIn format'
  end

  test 'should filter social by sciper' do
    scoped_socials = Social.for_sciper(@linkedin_social.profile.sciper)
    assert_includes scoped_socials, @linkedin_social, 'Should include social for specific sciper'
  end

  test 'should ensure sciper from profile' do
    assert_equal @linkedin_social.profile.sciper, @linkedin_social.send(:ensure_sciper),
                 'Should use profile sciper if sciper is not set'
  end

  test 'url_actually_exists should return true' do
    assert @linkedin_social.send(:url_actually_exists), 'URL existence check should return true as it is a placeholder'
  end

  test 'should show correct error message in French for blank value' do
    I18n.locale = :fr
    @linkedin_social.value = nil
    refute @linkedin_social.valid?, 'Social without a value should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.value.blank', locale: :fr)
    assert_includes @linkedin_social.errors[:value], error_message
  end

  test 'should show correct error message in French for invalid tag' do
    I18n.locale = :fr
    @linkedin_social.tag = 'invalid_tag'
    refute @linkedin_social.valid?, 'Social with invalid tag should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.tag.invalid', locale: :fr)
    assert_includes @linkedin_social.errors[:tag], error_message
  end

  test 'should show correct error message in French for incorrect format' do
    I18n.locale = :fr
    @linkedin_social.value = 'invalid*format'
    refute @linkedin_social.valid?, 'Social with invalid value format should not be valid'

    error_message = I18n.t('activerecord.errors.models.social.attributes.value.incorrect_format', locale: :fr)
    assert_includes @linkedin_social.errors[:value], error_message
  end
end
