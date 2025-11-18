# frozen_string_literal: true

class Award < ApplicationRecord
  belongs_to :profile
  include AudienceLimitable
  include Translatable
  include WithSelectableProperties
  include IndexBoxable
  include Versionable
  audience_limit
  with_selectable_properties :category, :origin
  translates :title
  positioned on: :profile

  before_validation :ensure_properties

  # relaxing this one because it would kill too many awards from legacy
  # validates :issuer, presence: true
  validates :year,
            presence: true,
            numericality: { only_integer: true, less_than_or_equal_to: Time.zone.today.year }
  validates :t_title, translatability: true

  delegate :sciper, to: :profile

  private

  def ensure_properties
    if category_id.blank?
      sp = Award.categories.where(default: true).first
      self.category = sp if sp.present?
    end
    return if category_id.present?

    sp = Award.origins.where(default: true).first
    self.origin = sp if sp.present?
  end
end
