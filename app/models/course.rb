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
    title_translated = send("title_#{locale}")
    return nil if code.blank? || title_translated.blank? || title_translated == "nil"

    t = I18n.transliterate(title_translated).gsub(/[^A-Za-z ]/, '').downcase.gsub(/\s+/, '-')
    c = code.upcase.gsub(/[()]/, '-').gsub('--', '-').gsub(/-$/, '')
    "https://edu.epfl.ch/coursebook/#{locale}/#{t}-#{c}"
  end
end
