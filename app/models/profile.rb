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

  # avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :profile_pictures, class_name: 'ProfilePicture', dependent: :destroy
  belongs_to :selected_picture, class_name: 'ProfilePicture', foreign_key: 'profile_picture_id', inverse_of: false
  has_many :accred_prefs, class_name: 'AccredPref', dependent: :destroy

  # TODO: switch to new model
  has_many :publications, class_name: 'Legacy::Publication', primary_key: 'sciper', foreign_key: 'sciper',
                          dependent: :destroy, inverse_of: :cv

  validates :sciper, uniqueness: { message: "must be unique" }

  def self.for_sciper(sciper)
    where(sciper: sciper).first
  end

  def photo_url
    show_photo ? photo_url! : nil
  end

  def photo_url!
    if selected_picture.present?
      Rails.application.routes.url_helpers.url_for(selected_picture.image)
    else
      camipro_photo_url
    end
  end

  def camipro_photo_url
    @camipro_photo_url ||= begin
      k = Rails.application.config_for(:epflapi).camipro_key
      t = Time.now.in_time_zone('Europe/Rome').strftime('%Y%m%d%H%M%S')
      baseurl = "https://#{Rails.application.config_for(:epflapi).camipro_host}/api/v1/photos/#{sciper}?time=#{t}&app=people"
      digest = OpenSSL::HMAC.hexdigest('SHA256', k, baseurl)
      baseurl + "&hash=#{digest}"
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
