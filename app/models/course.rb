# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class Course < ApplicationRecord
  establish_connection :work
  include Translatable
  has_many :course_instances, dependent: :destroy
  has_many :teacherships, dependent: :destroy
  validates :slug, uniqueness: { scope: :acad }

  translates :title, :description

  def self.new_from_oasis(ocourse)
    c = Course.new({
                     slug: ocourse.slug,
                     slug_prefix: ocourse.slug_prefix,
                     acad: ocourse.acad,
                   })
    c.update_from_oasis(ocourse)
    c
  end

  def update_from_oasis(ocourse)
    assign_attributes(ocourse.to_h.slice(:lang, :title_en, :title_fr))
    unless ocourse.description_en.blank? || ocourse.description_en.starts_with?("oracle.sql")
      self.description_en = ocourse.description_en
    end
    return if ocourse.description_fr.blank? || ocourse.description_fr.starts_with?("oracle.sql")

    self.description_fr = ocourse.description_fr
  end

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
    translated_title = t_title(locale)
    return nil if code.blank? || translated_title.blank?

    t = I18n.transliterate(translated_title).gsub(/[^A-Za-z ]/, '').downcase.gsub(/\s+/, '-')
    c = code.upcase.sub('(', "-").sub(')', '')
    "https://edu.epfl.ch/coursebook/#{locale}/#{t}-#{c}"
  end

  # TODO: this alias should no longer be needed
  def code
    slug
  end

  # TODO: I don't know if it makes sense to spare 4 columns like this knowing
  # that we do not have it or de lang from Oasis
  def title_it
    title_en
  end

  def title_de
    title_en
  end

  def description_it
    description_en
  end

  def description_de
    description_en
  end

  DINFO_CODES = Rails.application.config_for(:dinfo_codes)

  def section_en
    DINFO_CODES["en"]["section"].fetch(section, section)
  end

  def section_fr
    DINFO_CODES["fr"]["section"].fetch(section, section)
  end
end
