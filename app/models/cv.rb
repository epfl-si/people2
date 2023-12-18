class Cv < ApplicationRecord
  # predefined primary key will brake testing when labels are used in fixtures
  # therefore, although I would much prefer to have sciper as the primary key,
  # I decided to abandon the idea in favor of ehnanced fixture readability.
  # I will probably duplicate sciper value in all models where it can be useful.
  # https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html
  # self.primary_key = 'sciper'

  include Translatable
  translates :nationality, :title

  has_many :boxes

  # avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :profile_pictures, class_name: "ProfilePicture"
  belongs_to :selected_picture, class_name: "ProfilePicture", foreign_key: "profile_picture_id"

  def self.for_sciper(sciper)
    where(sciper:).first
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
      t = Time.now.in_time_zone("Europe/Rome").strftime("%Y%m%d%H%M%S")
      baseurl = "https://#{Rails.application.config_for(:epflapi).camipro_host}/api/v1/photos/#{sciper}?time=#{t}&app=people"
      digest = OpenSSL::HMAC.hexdigest("SHA256", k, baseurl)
      baseurl + "&hash=#{digest}"
    end
  end
end
