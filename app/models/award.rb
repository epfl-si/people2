# frozen_string_literal: true

class Award < ApplicationRecord
  belongs_to :profile
  include AudienceLimitable
  include Translatable
  translates :title
  positioned on: :profile

  validates :issuer, presence: true
  validates :year, presence: true
  validates :t_title, translatability: true
end
