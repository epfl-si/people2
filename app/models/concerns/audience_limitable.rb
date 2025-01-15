# frozen_string_literal: true

# This could be nicely implemented as enum but it is not yet implemented for mysql
# audience: 0=world, 1=intranet, 2=authenticated user
# visibility: 0=public, 1=draft, 2=hidden
# TODO: write unit tests
# TODO: when importing legacy data:
#       - visible => audience=0, visibility=0
#       - hidden  => audience=0, visibility=2

module AudienceLimitable
  AUDIENCE_OPTIONS = [
    { label: 'public', icon: 'globe' },
    { label: 'intranet', icon: 'home' },
    { label: 'authenticated', icon: 'user-check' }
  ].freeze

  VISIBILITY_OPTIONS = [
    { label: 'published', icon: 'eye' },
    { label: 'draft', icon: 'edit-3' },
    { label: 'hidden', icon: 'eye-off' }
  ].freeze

  extend ActiveSupport::Concern

  included do
    # Reminder: ranges do not include the upper limit
    scope :world_visible, -> { where(audience: 0, visibility: 0) }
    scope :intranet_visible, -> { where(audience: 0...2, visibility: 0) }
    scope :auth_visible, -> { where(audience: 0...3, visibility: 0) }
    scope :owner_visible, -> { where(visibility: 0...2) }
    scope :for_audience, ->(audience) { where(audience: 0...(audience + 1), visibility: 0) }
    validates :audience, numericality: { in: 0...3 }
    validates :visibility, numericality: { in: 0...3 }
  end

  def visible_by?(level = 0)
    audience <= level
  end

  def world_visible?
    visibilty.zero? && audience.zero?
  end

  def intranet_visible?
    visibilty.zero? && audience < 2
  end

  def auth_visible?
    visibilty.zero? && audience < 3
  end

  def owner_visible?
    visibility != 2
  end

  def hidden?
    visibility == 2
  end

  def visibility_label(v = visibility)
    VISIBILITY_OPTIONS[v][:label]
  end

  def audience_label(v = audience)
    AUDIENCE_OPTIONS[v][:label]
  end
end
