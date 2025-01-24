# frozen_string_literal: true

class SelectableProperty < ApplicationRecord
  include Translatable
  translates :name
  validates :label, uniqueness: { scope: :property }

  scope :award_category, -> { where(property: 'award_category') }
  scope :award_origin, -> { where(property: 'award_origin') }
  scope :achievement_category, -> { where(property: 'achievement_category') }
end
