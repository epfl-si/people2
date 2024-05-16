# frozen_string_literal: true

# This could be nicely implemented as enum but it is not yet implemented for mysql
# TODO: write unit tests
module AudienceLimitable
  extend ActiveSupport::Concern

  included do
    scope :world_visible, -> { where(visible: true, audience: 0) }
    scope :intranet_visible, -> { where(visible: true, audience: 0...2) }
    scope :auth_visible, -> { where(visible: true, audience: 0...3) }
    scope :owner_visible, -> { where(visible: true, audience: 0...4) }
    scope :for_audience, ->(audience) { where(visible: true, audience: 0...(audience + 1)) }
    validates :audience, numericality: { in: 0...4 }
  end

  def world_visible?
    (!has_attribute?(:visible) || visible?) && audience.zero?
  end

  def intranet_visible?
    (!has_attribute?(:visible) || visible?) && audience < 2
  end

  def auth_visible?
    (!has_attribute?(:visible) || visible?) && audience < 3
  end

  def owner_visible?
    (!has_attribute?(:visible) || visible?) && audience < 4
  end

  def hidden?
    has_attribute?(:visible) && !visible?
  end
end
