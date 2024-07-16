# frozen_string_literal: true

class Award < ApplicationRecord
  belongs_to :profile
  belongs_to :category, class_name: "SelectableProperty"
  belongs_to :origin, class_name: "SelectableProperty"
  include AudienceLimitable
  include Translatable
  translates :title
  positioned on: :profile

  validates :issuer, presence: true
  validates :year, presence: true
  validates :t_title, translatability: true

  def self.categories
    SelectableProperty.award_category
  end

  def self.origins
    SelectableProperty.award_origin
  end

  def t_origin(locale = "fr")
    origin.t_name(locale)
  end

  def t_category(locale = "fr")
    category.t_name(locale)
  end
end
