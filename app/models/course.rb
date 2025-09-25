# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class Course < ApplicationRecord
  establish_connection :work
  include Translatable
  translates :title, :description

  def self.new_from_oasis(ocode)
    c = Course.new
    c.update_from_oasis(ocode)
    c
  end

  def update_from_oasis(ocode)
    ocourse = ocode.course
    assign_attributes({
                        slug: ocode.code,
                        slug_prefix: ocode.slug_prefix,
                        acad: ocode.acad,
                        level: ocode.level,
                        section: ocode.section,
                        semester: ocode.semester,
                        lang: ocourse.lang,
                        title_en: ocourse.title_en,
                        title_fr: ocourse.title_fr,
                      })
    unless @description_en.blank? || @description_en.starts_with?("oracle.sql")
      c.description_en = ocourse.description_en
    end
    return if @description_fr.blank? || @description_fr.starts_with?("oracle.sql")

    c.description_fr = ocourse.description_fr
  end

  def self.current_academic_year(d = Time.zone.today)
    y = d.year
    if d.month < 8
      "#{y - 1}-#{y}"
    else
      "#{y}-#{y + 1}"
    end
  end

  def display_semester
    "#{slug_prefix} – #{level}"
  end

  def acad_semester
    "#{acad} / #{semester}"
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

  #   SECTION_NAMES = {
  #   "AR"         => "Architecture",
  #   "CGC"        => "Chimie et génie chimique",
  #   "CMS"        => "",
  #   "DH"         => "",
  #   "EDAM"       => "",
  #   "EDAR"       => "",
  #   "EDBB"       => "",
  #   "EDCB"       => "",
  #   "EDCE"       => "",
  #   "EDCH"       => "",
  #   "EDDH"       => "",
  #   "EDEE"       => "",
  #   "EDEY"       => "",
  #   "EDFI"       => "",
  #   "EDIC"       => "",
  #   "EDLS"       => "",
  #   "EDMA"       => "",
  #   "EDME"       => "",
  #   "EDMI"       => "",
  #   "EDMS"       => "",
  #   "EDMT"       => "",
  #   "EDMX"       => "",
  #   "EDNE"       => "",
  #   "EDOC-GE"    => "",
  #   "EDPO"       => "",
  #   "EDPY"       => "",
  #   "EDRS"       => "",
  #   "EL"         => "Génie électrique",
  #   "EME_MES"    => "",
  #   "GC"         => "",
  #   "GM"         => "",
  #   "IF"         => "",
  #   "IN"         => "",
  #   "MA"         => "Mathématiques",
  #   "MT"         => "",
  #   "MTE"        => "",
  #   "MX"         => "",
  #   "NX"         => "",
  #   "PH"         => "Physique",
  #   "PH_NE"      => "",
  #   "SC"         => "",
  #   "SHS"        => "",
  #   "SIE"        => "",
  #   "SIQ"        => "",
  #   "SV"         => "",
  # }
end
