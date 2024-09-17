# frozen_string_literal: true

require 'test_helper'

class RichTextBoxTest < ActiveSupport::TestCase
  def setup
    @gio_box_expertise_en = action_text_rich_texts(:gio_box_expertise_en)
    @gio_box_expertise_fr = action_text_rich_texts(:gio_box_expertise_fr)
    @nat_box_mission_fr = action_text_rich_texts(:nat_box_mission_fr)
    @nat_box_expertise_fr = action_text_rich_texts(:nat_box_expertise_fr)
    @oli_box_expertise_fr = action_text_rich_texts(:oli_box_expertise_fr)
  end

  test 'should return English content for gio expertise box' do
    I18n.locale = :en
    assert @gio_box_expertise_en.present?, 'Content should be present in English for gio_box_expertise_en'
    assert_includes @gio_box_expertise_en.body.to_plain_text, 'HPC, Algorithms',
                    'The English content should include expertise data'
  end

  test 'should return French content for gio expertise box' do
    I18n.locale = :fr
    assert @gio_box_expertise_fr.present?, 'Content should be present in French for gio_box_expertise_fr'
    assert_includes @gio_box_expertise_fr.body.to_plain_text,
                    'HPC, Algorithmes, Réseaux, Programmation, IT, DBA, Unix, Physique des solides computationnelle',
                    'The French content should include expertise data'
  end

  test 'should return French content for Natalie mission box' do
    I18n.locale = :fr
    assert @nat_box_mission_fr.present?, 'Content should be present in French for nat_box_mission_fr'
    assert_includes @nat_box_mission_fr.body.to_plain_text, 'graphisme',
                    'The French content should include mission data'
  end

  test 'should return English content for Natalie box' do
    I18n.locale = :en
    assert @nat_box_expertise_fr.present?, 'Content should be present in English for nat_box_expertise_fr'
    assert_includes @nat_box_expertise_fr.body.to_plain_text, 'architecture web',
                    'The English content should include web architecture data'
  end

  test 'should return French content for Olivier expertise box' do
    I18n.locale = :fr
    assert @oli_box_expertise_fr.present?, 'Content should be present in French for oli_box_expertise_fr'
    assert_includes @oli_box_expertise_fr.body.to_plain_text, 'Théorie de l\'information',
                    'The French content should include expertise data for Olivier'
  end

  #   test 'should return false for content in non-existent language' do
  #     I18n.locale = :de
  #     refute @gio_box_expertise_fr.content?(:de), 'Content should not be present in German for gio_box_expertise_fr'
  #   end
end
