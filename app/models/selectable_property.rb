# frozen_string_literal: true

class SelectableProperty < ApplicationRecord
  include Translatable
  translates :name
  validates :label, uniqueness: { scope: :property }
  after_save :single_default

  # scope :award_category, -> { where(property: 'award_category') }
  # scope :award_origin, -> { where(property: 'award_origin') }
  # scope :achievement_category, -> { where(property: 'achievement_category') }

  def title
    "#{property.titleize} | #{label}"
  end

  def single_default
    return unless default?

    other = SelectableProperty.where(property: property, default: true).where.not(id: id)
    other.each do |sp|
      sp.default = false
      sp.save
    end
  end

  # TODO: get rid of this "preventive optimization" shit
  def self.all_by_property
    @all_by_property ||= all.group_by(&:property)
  end

  def self.award_category
    all_by_property['award_category']
  end

  def self.award_origin
    all_by_property['award_origin']
  end

  def self.achievement_category
    all_by_property['achievement_category']
  end

  def self.motd_category
    all_by_property['motd_category']
  end

  def self.education_category
    all_by_property['education_category']
  end
end
