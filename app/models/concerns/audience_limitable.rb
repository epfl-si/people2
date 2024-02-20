# frozen_string_literal: true

# This could be nicely implemented as enum but it is not yet implemented for mysql
module AudienceLimitable
  extend ActiveSupport::Concern

  included do
    scope :world_visible, -> { where(visible: true, audience: 0) }
    scope :intranet_visible, -> { where(visible: true, audience: 0...1) }
    scope :auth_visible, -> { where(visible: true) }
    scope :for_audience, ->(audience) { where(visible: true, audience: 0...audience) }
    validates :audience, numericality: { in: 0...2 }
  end

  def world_visible?
    visible? && audience.zero?
  end

  def intranet_visible?
    visible? && audience < 2
  end

  def auth_visible?
    visible?
  end

  def hidden?
    !visible?
  end
end
