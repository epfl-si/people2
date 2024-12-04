# frozen_string_literal: true

require 'test_helper'

class NameTest < ActiveSupport::TestCase
  def setup
    @valid_name = Name.new(
      id: 1,
      usual_first: 'Johnathan',
      usual_last: 'Doe',
      official_first: 'Johnathan Hades',
      official_last: 'Doe'
    )

    @invalid_name = Name.new(
      id: 2,
      usual_first: 'Mike',
      usual_last: 'Smith',
      official_first: 'Michael',
      official_last: 'Johnson'
    )

    @customizable_name = Name.new(
      id: 3,
      usual_first: 'Hades',
      usual_last: 'Doe',
      official_first: 'Johnathan Hades',
      official_last: 'Doe Bloom'
    )
  end

  test "should be valid if usual names are derived from official names" do
    assert @valid_name.valid?, "Name should be valid when usual names are derived from official names"
  end

  test "should not be valid if usual names are not derived from official names" do
    assert_not @invalid_name.valid?, "Name should not be valid when usual names are not derived from official names"
    assert_includes @invalid_name.errors[:usual_first],
                    I18n.t('activemodel.errors.models.name.attributes.usual_first.not_in_official')
    assert_includes @invalid_name.errors[:usual_last],
                    I18n.t('activemodel.errors.models.name.attributes.usual_last.not_in_official')
  end

  test "display_first should return usual_first if present, otherwise first word of official_first" do
    assert_equal 'Johnathan', @valid_name.display_first, "display_first should return 'Johnathan'"
    @valid_name.usual_first = nil
    assert_equal 'Johnathan Hades', @valid_name.display_first,
                 "display_first should return 'Johnathan' if usual_first is nil"
  end

  test "display should return full name based on display_first and display_last" do
    assert_equal 'Johnathan Doe', @valid_name.display, "display should return 'Johnathan Doe'"
  end

  test "suggested_first should return the first word from official_first" do
    assert_equal 'Johnathan', @valid_name.suggested_first, "suggested_first should return 'Johnathan'"
  end

  test "customizable? should return true if either first or last name is customizable" do
    assert @customizable_name.customizable?, "Name should be customizable if first or last name can be customized"
  end

  test "customizable_first? should return true if official_first has more than one word" do
    assert @customizable_name.customizable_first?,
           "customizable_first? should return true if official_first has more than one word"
  end
end
