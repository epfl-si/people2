# frozen_string_literal: true

class Achievement < ApplicationRecord
  belongs_to :profile
  include AudienceLimitable
  include Translatable
  include WithSelectableProperties
  include IndexBoxable
  before_validation :ensure_year

  audience_limit
  with_selectable_properties :category
  translates :description
  positioned on: :profile

  # No need to validate as the year is programmatically set
  # validates :year,
  #           presence: true,
  #           numericality: { only_integer: true, less_than_or_equal_to: Time.zone.today.year }
  # TODO: uncomment this and it will crash. Why ?
  # validates :description, translatability: true

  private

  # Until end of April, there is still time to add previous year's achievements
  def ensure_year
    return if year.present?

    today = DateTime.now
    self.year = if today.month <= 4
                  today.year - 1
                else
                  today.year
                end
  end
end
