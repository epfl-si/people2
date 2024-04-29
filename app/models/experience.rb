# frozen_string_literal: true

class Experience < ApplicationRecord
  include AudienceLimitable
  include Translatable

  belongs_to :profile
  broadcasts_to :profile

  translates :title, :field
  translates_rich_text :description

  validates :t_title, translatability: true
  # validates :t_field, translatability: true
  validates :location, presence: true
  validates :year_end, presence: true
end
