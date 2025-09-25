# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class CourseInstance < ApplicationRecord
  establish_connection :work
  belongs_to :course
  before_validation :ensure_course_id
  validates :course_id, presence: true
  validates :slug, presence: true
  include Translatable
  translates :section

  def acad_semester
    "#{acad} / #{semester}"
  end

  def code
    slug
  end

  def ensure_course_id
    return if course_id.present?

    c = Course.find(slug: slug)
    return if c.blank?

    self.course_id = c.id
  end

  def section_en
    Rails.application.config_for(:dinfo_codes).en.fetch(:section).fetch(section.to_sym)
  end

  def section_fr
    Rails.application.config_for(:dinfo_codes).fr.fetch(:section).fetch(section.to_sym)
  end

  def section_it
    section_en
  end

  def section_de
    section_en
  end
end
