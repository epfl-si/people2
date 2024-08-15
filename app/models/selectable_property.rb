# frozen_string_literal: true

class SelectableProperty < ApplicationRecord
  include Translatable
  translates :name
  scope :award_category, -> { where(property: 'award_category') }
  scope :award_origin, -> { where(property: 'award_origin') }
end
