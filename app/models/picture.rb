# frozen_string_literal: true

# TODO: periodic job fetching outdated camipro pictures
require 'open-uri'

class Picture < ApplicationRecord
  MAX_ATTEMPTS = 3

  before_destroy :refuse_destroy_if_camipro

  belongs_to :profile
  has_one_attached :image do |attachable|
    attachable.variant :small, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [200, 200]
    attachable.variant :large, resize_to_limit: [400, 400]
    attachable.variant :huge, resize_to_limit: [800, 800]
  end
  has_one_attached :cropped_image do |attachable|
    attachable.variant :small, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [200, 200]
    attachable.variant :large, resize_to_limit: [400, 400]
    attachable.variant :huge, resize_to_limit: [800, 800]
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

  private

  def refuse_destroy_if_camipro
    return unless camipro?
    # We still allow to destroy picture if it's profile is being destroyed too
    return if destroyed_by_association

    errors.add :base, "activerecord.errors.picture.attributes.base.undeletable"
    throw :abort
  end
end
