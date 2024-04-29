# frozen_string_literal: true

class Name
  attr_accessor :id, :usual_first, :usual_last, :official_first, :official_last

  include ActiveModel::API
  extend ActiveModel::Naming

  validate :usual_names_are_taken_from_official

  def display_first
    usual_first || official_first
  end

  def display_last
    usual_last || official_last
  end

  def display
    "#{display_first} #{display_last}"
  end

  def suggested_first
    official_first.split(/\W+/).first
  end

  def suggested_last
    official_last.split(/\W+/).first
  end

  def customizable?
    customizable_first? || customizable_last?
  end

  def customizable_first?
    official_first.split(/\W+/).count > 1
  end

  def customizable_last?
    official_first.split(/\W+/).count > 1
  end

  def usual_names_are_taken_from_official
    unless usual_first.nil?
      of = official_first.split(/\W+/)
      errors.add(:usual_first, :not_in_official) unless usual_first.split(/\W+/).all? { |w| of.include?(w) }
    end
    return if usual_last.nil?

    of = official_last.split(/\W+/)
    return if usual_last.split(/\W+/).all? { |w| of.include?(w) }

    errors.add(:usual_last, :not_in_official)
  end
end
