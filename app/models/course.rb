# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class Course < ApplicationRecord
  establish_connection :work
  include Translatable
  has_many :course_instances, dependent: :destroy
  has_many :teacherships, dependent: :destroy
  validates :slug, uniqueness: { scope: :acad }

  # only the "urled" courses with a valid link to edu.epfl.ch should be retained
  scope :visible, -> { where(urled: true) }

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

  def self.search(filters)
    filters[:acad] ||= current_academic_year
    instance_filters = filters.slice(:acad, :level, :section, :semester).compact_blank
    course_filters = filters.slice(:acad, :slug_prefix).compact_blank
    teachership_filters = { role: "Enseignement" }.merge(filters.slice(:sciper)).compact_blank

    Rails.logger.debug("Course::search. instance_filters=#{instance_filters.inspect}")
    Rails.logger.debug("Course::search. course_filters=#{course_filters.inspect}")
    Rails.logger.debug("Course::search. teachership_filters=#{teachership_filters.inspect}")

    visible.where(
      course_filters
    ).includes(
      :course_instances, :teacherships
    ).where(
      course_instances: instance_filters,
      teacherships: teachership_filters
    )
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

  def teacher_names
    teacherships.map(&:display_name)
  end

  def teacher_scipers
    teacherships.map(&:sciper)
  end

  def verified_edu_url!(locale)
    fbl = send "fallback_url_#{locale}"
    if fbl.nil?
      check_edu_urls
      save
      fbl = send "fallback_url_#{locale}"
    end
    return nil if fbl == "NA"

    edu_url(fbl)
  end

  def edu_url(locale)
    edu_url_mix(locale)
  end

  def edu_url_mix(locale)
    t = t_title(locale)
    return nil if code.blank? || t.blank?

    t = I18n.transliterate(t).strip.downcase.gsub(%r{[\s():,;./?&#'"\\+]+}, '-')
    c = slug.strip.upcase.gsub(%r{[\s():,;./?&#'"\\+]+}, '-')
    s = "#{t}-#{c}".gsub(/-+|-$/, "-")
    "https://edu.epfl.ch/coursebook/#{locale}/#{s}"
  end

  # Return the url for the course description in edu.epfl.ch
  def edu_url_giova(locale)
    # TODO: check with William in order to have exactly the same algorithm
    #       to build the url from title+code. In particular, when
    #       1. code or title is absent
    #       2. the title is not present in the selected locale
    #       Iteally, William should include the url in the data so we don't
    #       have to play the cat and mouse game
    translated_title = t_title(locale)
    return nil if code.blank? || translated_title.blank?

    t = I18n.transliterate(translated_title).strip.downcase.gsub(/[^a-z0-9-]+/, '-')
    c = code.upcase.sub('(', "-").sub(')', '')
    s = "#{t}-#{c}".gsub(/-+/, "-")
    "https://edu.epfl.ch/coursebook/#{locale}/#{s}"
  end

  # Like edu_url but with an implementation more similar to William's
  # def clean_string(data):
  #     rr = r'[\s\(\):,;\./\?&#\'"\+]'
  #     e = unicodedata.normalize('NFD', data).encode('ASCII', 'ignore').decode('ASCII')
  #     e = re.sub(rr, '-', e)
  #     e = re.sub("-{2,}", '-', e)
  #     return re.sub('-+$', '', e)
  # def get_clean_url(_title, _code):
  #     return clean_string(_title).lower() + '-' + \
  #       clean_string(_code).upper() if _code else clean_string(_title).lower()
  def edu_url_william(locale)
    translated_title = t_title(locale).strip
    return nil if code.blank? || translated_title.blank?

    sl, ti = [slug, t_title(locale).strip].map do |s|
      s.encode('ASCII', invalid: :replace, undef: :replace, replace: '')
       .gsub(%r{[\s():,;./?&#'"\\+]}, '-').gsub(/-{2,}/, '-').gsub(/-+$/, '')
    end
    b = "https://edu.epfl.ch/coursebook/#{locale}"
    if sl.present?
      "#{b}/#{ti.downcase}-#{sl.upcase}"
    else
      "#{b}/#{ti.downcase}"
    end
  end
  # Course.all.each do |c|
  #   w=c.edu_url_william("en")
  #   g=c.edu_url("en")
  #   unless w == g
  #     puts "#{c.id} #{c.slug} #{c.title_en} -> #{w} <=> #{g}"
  #   end
  # end

  def check_edu_urls(http = nil)
    if %w[UNIL PREPA].include?(slug_prefix)
      self.fallback_url_en = "NA"
      self.fallback_url_fr = "NA"
      self.urled = false
      return
    end
    if http.nil?
      Net::HTTP.start("edu.epfl.ch", 443, use_ssl: true) do |http|
        http_check_edu_urls(http)
      end
    else
      http_check_edu_urls(http)
    end
  end

  def http_check_edu_urls(http)
    fok = nil
    us = %w[en fr].map do |l|
      uri = edu_url(l)
      request = Net::HTTP::Head.new(uri)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        fok ||= l
        l
      end
    end
    self.urled = us.compact.count.positive?
    self.fallback_url_en, self.fallback_url_fr = us.map { |v| v || fok || "NA" }
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

  def fallback_url_it
    fallback_url_en
  end

  def fallback_url_de
    fallback_url_en
  end
end
