# frozen_string_literal: true

require "application_system_test_case"

module Admin
  class TranslationsTest < ApplicationSystemTestCase
    setup do
      @admin_translation = admin_translations(:one)
    end

    test "visiting the index" do
      visit admin_translations_url
      assert_selector "h1", text: "Translations"
    end

    test "should create translation" do
      visit admin_translations_url
      click_on "New translation"

      fill_in "De", with: @admin_translation.de
      check "Done" if @admin_translation.done
      fill_in "En", with: @admin_translation.en
      fill_in "File", with: @admin_translation.file
      fill_in "Fr", with: @admin_translation.fr
      fill_in "It", with: @admin_translation.it
      click_on "Create Translation"

      assert_text "Translation was successfully created"
      click_on "Back"
    end

    test "should update Translation" do
      visit admin_translation_url(@admin_translation)
      click_on "Edit this translation", match: :first

      fill_in "De", with: @admin_translation.de
      check "Done" if @admin_translation.done
      fill_in "En", with: @admin_translation.en
      fill_in "File", with: @admin_translation.file
      fill_in "Fr", with: @admin_translation.fr
      fill_in "It", with: @admin_translation.it
      click_on "Update Translation"

      assert_text "Translation was successfully updated"
      click_on "Back"
    end

    test "should destroy Translation" do
      visit admin_translation_url(@admin_translation)
      click_on "Destroy this translation", match: :first

      assert_text "Translation was successfully destroyed"
    end
  end
end
