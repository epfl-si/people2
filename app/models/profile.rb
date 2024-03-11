# frozen_string_literal: true

# Profile is the former _common_ table where we store most of the simple
# editable user's data.
# The read-only official data comes from external sources like
# accred & co. via api.epfl.ch and ISAcademia.

class Profile < ApplicationRecord
  # predefined primary key will brake testing when labels are used in fixtures
  # therefore, although I would much prefer to have sciper as the primary key,
  # I decided to abandon the idea in favor of ehnanced fixture readability.
  # I will probably duplicate sciper value in all models where it can be useful.
  # https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html
  # self.primary_key = 'sciper'

  include Translatable
  translates :nationality, :title

  has_many :boxes, dependent: :destroy
  has_many :socials, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :experiences, dependent: :destroy

  # TIP: avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :profile_pictures, class_name: 'ProfilePicture', dependent: :destroy
  belongs_to :selected_picture, class_name: 'ProfilePicture',
                                foreign_key: 'profile_picture_id', optional: true, inverse_of: false
  has_many :accred_prefs, class_name: 'AccredPref', dependent: :destroy
  has_one :camipro_picture, class_name: 'CamiproPicture', dependent: :destroy

  # TODO: switch to new model
  has_many :publications, class_name: 'Legacy::Publication', primary_key: 'sciper', foreign_key: 'sciper',
                          dependent: :destroy, inverse_of: :cv

  # has_and_belongs_to_many :courses, join_table: "teacherships"
  has_many :teacherships, class_name: "Teachership", dependent: :destroy
  has_many :courses, through: :teacherships

  validates :sciper, uniqueness: { message: "must be unique" }

  def self.create_with_defaults(sciper)
    create(
      sciper: sciper,
      show_birthday: false,
      show_function: true,
      show_nationality: false,
      show_phone: true,
      show_photo: false,
      show_title: false,
      force_lang: nil,
      personal_web_url: nil,
      nationality_en: nil,
      nationality_fr: nil,
      title_en: nil,
      title_fr: nil
    )
  end

  def self.for_sciper(sciper)
    where(sciper: sciper).first
  end

  def photo
    show_photo ? photo! : nil
  end

  def photo!
    if selected_picture.present?
      selected_picture
    elsif camipro_picture.present?
      camipro_picture
    else
      create_camipro_picture!
    end
  end

  def any_publication?
    publications.present?
  end

  # Birthday is no long available in data from api
  def show_birthday?
    false
  end

  def birthday
    nil
  end
end
