# frozen_string_literal: true

class Experience < ApplicationRecord
  include AudienceLimitable
  include Translatable

  belongs_to :profile

  # broadcasts_to :profile

  translates :title, :field
  translates_rich_text :description

  before_validation :complete_period

  validates :t_title, translatability: true
  validates :location, presence: true
  validates :year_begin, presence: true
  validates :year_end, presence: true
  # validate :has_at_least_one_year

  private

  def complete_period
    self.year_begin ||= year_end
    self.year_end ||= self.year_begin
  end

  # def has_at_least_one_year
  #   return if year_begin.present? || year_end.present?
  #   errors.add(:base, :missing_year)
  # end
end
