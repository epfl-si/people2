# frozen_string_literal: true

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  def setup
    @profile = profiles(:natalie)
    @valid_publication = Publication.new(
      title: 'A Valid Publication',
      year: 2023,
      url: 'https://example.com',
      authors: 'John Doe',
      journal: 'Journal of Testing',
      position: 1,
      profile: @profile
    )
  end

  test 'should not save publication without title' do
    @valid_publication.title = nil
    refute @valid_publication.valid?, 'Publication without a title should not be valid'
    assert_includes @valid_publication.errors[:title], "can't be blank"
  end

  test 'should only accept numeric year' do
    @valid_publication.year = 'Not a year'
    refute @valid_publication.valid?, 'Publication with non-numeric year should not be valid'
    assert_includes @valid_publication.errors[:year], 'is not a number'
  end

  test 'should allow blank year' do
    @valid_publication.year = nil
    assert @valid_publication.valid?, 'Publication with blank year should be valid'
  end

  test 'should validate URL format' do
    @valid_publication.url = 'invalid_url'
    refute @valid_publication.valid?, 'Publication with invalid URL should not be valid'
    assert_includes @valid_publication.errors[:url], 'is invalid'
  end

  test 'should allow blank URL' do
    @valid_publication.url = ''
    assert @valid_publication.valid?, 'Publication with blank URL should be valid'
  end

  test 'should save valid publication' do
    assert @valid_publication.save, 'Valid publication should be saved successfully'
  end

  test 'should belong to a profile' do
    assert_equal @profile, @valid_publication.profile, 'Publication should belong to a profile'
  end
end
