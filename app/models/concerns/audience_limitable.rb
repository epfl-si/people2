# frozen_string_literal: true

# This could be nicely implemented as enum but it is not yet implemented for mysql
# TODO: write unit tests
# TODO: when importing legacy data:
#       - visible => audience=0
#       - hidden  => audience=4
module AudienceLimitable
  extend ActiveSupport::Concern

  included do
    scope :world_visible, -> { where(audience: 0) }
    scope :intranet_visible, -> { where(audience: 0...2) }
    scope :auth_visible, -> { where(audience: 0...3) }
    scope :owner_visible, -> { where(audience: 0...4) }
    scope :for_audience, ->(audience) { where(audience: 0...(audience + 1)) }
    validates :audience, numericality: { in: 0...5 }
  end

  def visible_by?(level = 0)
    audience <= level
  end

  def world_visible?
    audience.zero?
  end

  def intranet_visible?
    audience < 2
  end

  def auth_visible?
    audience < 3
  end

  def owner_visible?
    audience < 4
  end

  def hidden?
    audience > 3
  end
end
