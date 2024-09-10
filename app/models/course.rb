# frozen_string_literal: true

class Course < ApplicationRecord
  include Translatable
  translates :title, :language

  # has_and_belongs_to_many :teachers, join_table: "teacherships", foreign_key: "profile_id"
  has_many :teacherships, class_name: "Teachership", dependent: :destroy
  has_many :teachers, through: :teacherships

  def self.current_academic_year(d = Time.zone.today)
    y = d.year
    if d.month < 8
      "#{y - 1}-#{y}"
    else
      "#{y}-#{y + 1}"
    end
  end

  def edu_url(locale)
    # TODO: check with William in order to have exactly the same algorithm
    #       to build the url from title+code. In particular, when
    #       1. code or title is absent
    #       2. the title is not present in the selected locale
    #       Iteally, William should include the url in the data so we don't
    #       have to play the cat and mouse game
    translated_title = t_title!(locale)
    return nil if code.blank? || translated_title.blank?

    t = I18n.transliterate(translated_title).gsub(/[^A-Za-z ]/, '').downcase.gsub(/\s+/, '-')
    c = code.upcase.sub('(', "-").sub(')', '')
    "https://edu.epfl.ch/coursebook/#{locale}/#{t}-#{c}"
  end
end
