# frozen_string_literal: true

class Structure < ApplicationRecord
  serialize :data, coder: JSON
  validates :label, uniqueness: true
  validate :check_sections_count_match

  def self.load(label, lang = 'en')
    if ["1", 1].include?(label)
      label = lang == 'en' ? "default_en_struct" : "default_struct"
    end
    where(label: label).first
  end

  def sections
    @sections ||= data.map do |d|
      f = PositionFilter.new(d["filter"])
      OpenStruct.new(title: d["title"], filter: f, items: []) if f.valid?
    end.compact
  end

  def check_sections_count_match
    sections.count == data.count
  end

  def store(person)
    sections.each do |f|
      if person.match_position_filter?(f.filter)
        f.items << person
        return true
      end
    end
    false
  end
end
