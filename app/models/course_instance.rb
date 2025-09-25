# frozen_string_literal: true

# This model is now just a proxy/cache used exclusively to get the titles and descriptions
class CourseInstance < ApplicationRecord
  establish_connection :work
  belongs_to :course
  before_validation :ensure_course_id
  validates :course_id, presence: true
  validates :slug, presence: true

  # def self.new_from_oasis(ocode)
  #   c = Course.new
  #   c.update_from_oasis(ocode)
  #   c
  # end

  # def update_from_oasis(ocode)
  #   assign_attributes({
  #                       slug: ocode.code,
  #                       acad: ocode.acad,
  #                       level: ocode.level,
  #                       section: ocode.section,
  #                       semester: ocode.semester,
  #                     })
  # end

  def display_semester
    "#{slug_prefix} – #{level}"
  end

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
end
