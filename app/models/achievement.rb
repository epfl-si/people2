# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :profile
  include AudienceLimitable
  include Translatable
  include WithSelectableProperties
  include IndexBoxable
  with_selectable_properties :category
  translates :description
  positioned on: :profile

  validates :year,
            presence: true,
            numericality: { only_integer: true, less_than_or_equal_to: Time.zone.today.year }
  # TODO: uncomment this and it will crash. Why ?
  # validates :description, translatability: true
end
