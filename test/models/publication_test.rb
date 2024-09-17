# frozen_string_literal: true

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  def setup
    @profile = profiles(:giova)
    @valid_publication = publications(:gio_publication0)
  end

  test 'should save valid publication from fixtures' do
    I18n.locale = :en
    assert @valid_publication.valid?, 'Publication from fixtures should be valid'
    assert @valid_publication.save, 'Valid publication from fixtures should be saved successfully'
  end

  test 'should save valid publication with correct data' do
    publication = Publication.new(
      title: 'Another Valid Publication',
      year: 2021,
      url: 'https://valid-url.com',
      authors: 'Jane Doe',
      journal: 'Journal of Valid Publications',
      position: 2,
      profile: @profile
    )
    I18n.locale = :en
    assert publication.valid?, 'Publication with valid data should be valid in English'
    assert publication.save, 'Valid publication should be saved successfully'

    I18n.locale = :fr
    assert publication.valid?, 'La publication avec des données valides devrait être valide en français'
    assert publication.save, 'La publication valide devrait être enregistrée avec succès'
  end

  test 'should belong to a profile' do
    assert_equal @profile, @valid_publication.profile, 'Publication should belong to a profile in English'

    I18n.locale = :fr
    assert_equal @profile, @valid_publication.profile, 'La publication devrait appartenir à un profil en français'
  end

  test 'should have correct visibility and audience' do
    assert @valid_publication.visible?, 'Publication should be visible'
    assert_equal 0, @valid_publication.audience, 'Publication should have public audience by default in English'

    I18n.locale = :fr
    assert @valid_publication.visible?, 'La publication devrait être visible en français'
    assert_equal 0, @valid_publication.audience, 'La publication devrait avoir un public par défaut en français'
  end

  test 'should display error messages in French' do
    I18n.locale = :fr

    publication = Publication.new(
      year: 2023,
      url: 'https://example.com',
      authors: 'John Doe',
      journal: 'Journal de test',
      position: 1,
      profile: @profile
    )

    refute publication.valid?, 'La publication sans titre ne devrait pas être valide'
    assert_includes publication.errors[:title], "ne peut pas être vide",
                    'Le message d’erreur "doit être rempli(e)" devrait être affiché en français'

    publication.year = 'Not a year'
    refute publication.valid?, 'La publication avec une année non numérique ne devrait pas être valide'
    assert_includes publication.errors[:year], "n'est pas un nombre",
                    'Le message d’erreur "n’est pas un nombre" devrait être affiché en français'

    publication.url = 'invalid_url'
    refute publication.valid?, 'La publication avec une URL invalide ne devrait pas être valide'
    assert_includes publication.errors[:url], "l'url est invalide",
                    'Le message d’erreur "n’est pas valide" devrait être affiché en français'
  end

  test 'should display error messages in English' do
    I18n.locale = :en

    publication = Publication.new(
      year: 2023,
      url: 'https://example.com',
      authors: 'John Doe',
      journal: 'Testing Journal',
      position: 1,
      profile: @profile
    )

    refute publication.valid?, 'Publication without a title should not be valid'
    assert_includes publication.errors[:title], "can't be blank",
                    'Error message "can\'t be blank" should be displayed in English'

    publication.year = 'Not a year'
    refute publication.valid?, 'Publication with non-numeric year should not be valid'
    assert_includes publication.errors[:year], 'is not a number',
                    'Error message "is not a number" should be displayed in English'

    publication.url = 'invalid_url'
    refute publication.valid?, 'Publication with invalid URL should not be valid'
    assert_includes publication.errors[:url], 'is invalid', 'Error message "is invalid" should be displayed in English'
  end

  teardown do
    I18n.locale = I18n.default_locale
  end
end
