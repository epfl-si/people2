# frozen_string_literal: true

class Course < ApplicationRecord
  include Translatable
  translates :title, :language

  # has_and_belongs_to_many :teachers, join_table: "teacherships", foreign_key: "profile_id"
  has_many :teacherships, class_name: "Teachership", dependent: :destroy
  has_many :teachers, through: :teacherships

  def self.current_academic_year
    d = Time.zone.today
    y = d.year
    if d.month < 8
      "#{y - 1}-#{y}"
    else
      "#{y}-#{y + 1}"
    end
  end

  def edu_url(locale)
    t = t_title(locale).gsub(/[^A-Za-z ]/, '').downcase.gsub(/\s+/, '-')
    c = code.upcase.sub('(', "-").sub(')', '')
    "https://edu.epfl.ch/coursebook/#{locale}/#{t}-#{c}"
  end
end
