# frozen_string_literal: true

require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  def setup
    @contact_section = sections(:contact)
    @bio_section = sections(:bio)
    @pub_section = sections(:pub)
  end

  test 'should return English title for section' do
    assert_equal 'Contact', @contact_section.title_en, 'Title should be "Contact" in English for the contact section'
  end

  test 'should return French title for section' do
    assert_equal 'Contact', @contact_section.title_fr, 'Title should be "Contact" in French for the contact section'
    assert_equal 'Biographie', @bio_section.title_fr, 'Title should be "Biographie" in French for the bio section'
  end

  test 'should return false for content if no boxes present' do
    mock_boxes = Minitest::Mock.new
    mock_boxes.expect :present?, false
    @contact_section.stub :boxes, mock_boxes do
      refute @contact_section.content?(:en), 'Content should be false if there are no boxes'
    end
    mock_boxes.verify
  end

  test 'should return true if visible content exists in boxes' do
    visible_box = Minitest::Mock.new
    visible_box.expect :visible?, true
    visible_box.expect :content?, true, [:en]

    @contact_section.stub :boxes, [visible_box] do
      assert @contact_section.content?(:en), 'Content should return true if visible content exists in English'
    end
    visible_box.verify
  end

  test 'should return false if no visible content in boxes' do
    non_visible_box = Minitest::Mock.new
    non_visible_box.expect :visible?, false

    @contact_section.stub :boxes, [non_visible_box] do
      refute @contact_section.content?(:en), 'Content should return false if no visible content in boxes'
    end
    non_visible_box.verify
  end

  test 'should allow creation based on create_allowed flag' do
    assert @contact_section.create_allowed, 'Create should be allowed for contact section'
    refute Section.new(create_allowed: false).create_allowed, 'Create should not be allowed when flag is false'
  end

  test 'should have the correct position' do
    assert_equal 1, @contact_section.position, 'Contact section should have position 1'
    assert_equal 2, @bio_section.position, 'Bio section should have position 2'
    assert_equal 3, @pub_section.position, 'Pub section should have position 3'
  end
end
