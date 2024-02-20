# frozen_string_literal: true

class Education < ApplicationRecord
  include AudienceLimitable
  include Translatable

  belongs_to :profile

  translates :title, :field

  validates :school, presence: true
  validates :t_title, translatability: true
  validates :t_field, translatability: true
end
