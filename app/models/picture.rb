# frozen_string_literal: true

# TODO: periodic job fetching outdated camipro pictures
require 'open-uri'

class Picture < ApplicationRecord
  MAX_ATTEMPTS = 3

  before_destroy :refuse_destroy_if_camipro

  belongs_to :profile
  has_one_attached :image do |attachable|
    # resize with pad to avoid tombstone photo effect
    attachable.variant :small, resize_and_pad: [100, 100, { background: [255] }]
    attachable.variant :small2, resize_and_pad: [200, 200, { background: [255] }]
    attachable.variant :small3, resize_and_pad: [300, 300, { background: [255] }]
    attachable.variant :medium, resize_and_pad: [200, 200, { background: [255] }]
    attachable.variant :medium2, resize_and_pad: [400, 400, { background: [255] }]
    attachable.variant :medium3, resize_and_pad: [600, 600, { background: [255] }]
    attachable.variant :large, resize_to_limit: [300, 300]
    attachable.variant :large2, resize_to_limit: [600, 600]
    attachable.variant :large3, resize_to_limit: [900, 900]
  end
  has_one_attached :cropped_image do |attachable|
    attachable.variant :small, resize_and_pad: [100, 100, { background: [255] }]
    attachable.variant :small2, resize_and_pad: [200, 200, { background: [255] }]
    attachable.variant :small3, resize_and_pad: [300, 300, { background: [255] }]
    attachable.variant :medium, resize_and_pad: [200, 200, { background: [255] }]
    attachable.variant :medium2, resize_and_pad: [400, 400, { background: [255] }]
    attachable.variant :medium3, resize_and_pad: [600, 600, { background: [255] }]
    attachable.variant :large, resize_to_limit: [300, 300]
    attachable.variant :large2, resize_to_limit: [600, 600]
    attachable.variant :large3, resize_to_limit: [900, 900]
  end

  after_commit :check_attachment

  scope :camipro, -> { where(camipro: true) }

  # -------------------------------------------------------------------- camipro

  def self.camipro_url(sciper)
    k = Rails.application.config_for(:epflapi).camipro_key
    t = Time.now.in_time_zone('Europe/Rome').strftime('%Y%m%d%H%M%S')
    baseurl = "https://#{Rails.application.config_for(:epflapi).camipro_host}/api/v1/photos/#{sciper}?time=#{t}&app=people"
    digest = OpenSSL::HMAC.hexdigest('SHA256', k, baseurl)
    baseurl + "&hash=#{digest}"
  end

  def visible_image
    if cropped_image&.attached?
      cropped_image
    elsif image&.attached?
      image
    end
  end

  def selected?
    id == profile.selected_picture_id
  end

  def fetch!
    return unless camipro?

    sciper = profile.sciper
    url = URI.parse(Picture.camipro_url(sciper))
    image.attach(io: url.open, filename: "#{sciper}.jpg")
  end

  def fetch
    return unless camipro?

    CamiproPictureCacheJob.perform_later(id) if failed_attempts < MAX_ATTEMPTS
  end

  def check_attachment
    fetch if camipro? && image.blank?
  end

  def force_destroy
    self.camipro = false
    destroy
  end

  def fetch_from_legacy!
    return if camipro?
    raise "Picture::fetch_from_legacy! only allowed during migration" unless Rails.configuration.enable_adoption

    cfg = Rails.application.config_for(:epflapi)
    token = Base64.encode64("#{cfg.username}:#{cfg.password}")
    sciper = profile.sciper
    url = URI("#{cfg.legacy_photo_url}?token=#{token}&app=peoplenext&sciper=#{sciper}")
    image.attach(io: url.open, filename: "#{sciper}.jpg")
  end

  private

  def refuse_destroy_if_camipro
    return unless camipro?
    # We still allow to destroy picture if it's profile is being destroyed too
    return if destroyed_by_association

    errors.add :base, "activerecord.errors.picture.attributes.base.undeletable"
    throw :abort
  end
end
