# frozen_string_literal: true

module Oasis
  class CourseCode < OpenStruct
    def initialize(data)
      super({
        acad: data['curriculumAnneeAcademique'],
        slug: data['coursCode'],
        level: data['curriculumNiveau'],
        section: data['matiereUnite'],
        semester: data['curriculumSemestre'],
      })
    end

    def course
      @course ||= OasisCourseGetter.call(acad: acad, code: code)
    end

    def slug_prefix
      @code.split("-").first
    end

    def ==(other)
      [acad, slug, section, level,
       semester] == [other.acad, other.slug, other.section, other.level, other.semester]
    end
  end
end
