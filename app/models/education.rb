# frozen_string_literal: true

class Education < ApplicationRecord
  include AudienceLimitable
  include Translatable
  include IndexBoxable
  include WithSelectableProperties
  with_selectable_properties :category

  belongs_to :profile
  positioned on: :profile

  audience_limit
  translates :title, :field

  validates :school, presence: true
  validates :t_title, translatability: true

  validates :year_begin, presence: true
  validates :year_end, presence: true

  # TODO: not sure field needs to be mandatory... see with PM
  # For example high school diploma does not strictly have a field
  # validates :t_field, translatability: true
end
