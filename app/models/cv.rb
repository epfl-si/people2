class Cv < ApplicationRecord
  include Translatable

  translates :nationality, :title
  has_many :boxes

  # avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :profile_pictures, :class_name => "ProfilePicture", :foreign_key => "cv_id"
  belongs_to :selected_picture, :class_name => "ProfilePicture", :foreign_key => "profile_picture_id"

  def self.for_sciper(sciper)
    self.where(sciper: sciper).first
  end

  def sciper
    self.id
  end

  def sciper=(v)
    self.id=(v.to_i)
  end

  def photo_url
    self.show_photo ? photo_url! : nil
  end

  def photo_url!
    self.selected_picture.present? ?
      Rails.application.routes.url_helpers.url_for(self.selected_picture.image)
      : camipro_photo_url
  end

  def camipro_photo_url
    @camipro_photo_url ||= begin
      k=Rails.configuration.camipro_key
      t=Time.now.in_time_zone("Europe/Rome").strftime("%Y%m%d%H%M%S")
      baseurl="https://#{Rails.configuration.camipro_host}/api/v1/photos/#{sciper}?time=#{t}&app=people"
      digest=OpenSSL::HMAC.hexdigest("SHA256", Rails.configuration.camipro_key, baseurl)
      baseurl + "&hash=#{digest}"
    end
  end
end
