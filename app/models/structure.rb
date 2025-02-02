# frozen_string_literal: true

class Structure < ApplicationRecord
  serialize :data, coder: JSON
  validates :label, uniqueness: true
  def self.load(label, lang = 'en')
    if ["1", 1].include?(label)
      label = lang == 'en' ? "default_en_struct" : "default_struct"
    end
    where(label: label).first
  end

  def filters
    @filters ||= data.map do |d|
      f = PositionFilter.new(d["filter"])
      OpenStruct.new(title: d["title"], filter: f) if f.valid?
    end.compact
  end
end
