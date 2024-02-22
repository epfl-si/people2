# frozen_string_literal: true

require 'open-uri'
# TODO: periodic job fetching outdated camipro pictures
class CamiproPicture < ApplicationRecord
  MAX_ATTEMPTS = 3

  belongs_to :profile
  has_one_attached :image

  after_commit :check_attachment

  def self.url(sciper)
    k = Rails.application.config_for(:epflapi).camipro_key
    t = Time.now.in_time_zone('Europe/Rome').strftime('%Y%m%d%H%M%S')
    baseurl = "https://#{Rails.application.config_for(:epflapi).camipro_host}/api/v1/photos/#{sciper}?time=#{t}&app=people"
    digest = OpenSSL::HMAC.hexdigest('SHA256', k, baseurl)
    baseurl + "&hash=#{digest}"
  end

  def fetch!
    sciper = profile.sciper
    url = URI.parse(CamiproPicture.url(sciper))
    image.attach(io: url.open, filename: "#{sciper}jpg")
  end

  def fetch
    CamiproPictureCacheJob.perform_later(id) if failed_attempts < MAX_ATTEMPTS
  end

  def check_attachment
    fetch if image.blank?
  end
end
