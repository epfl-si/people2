# frozen_string_literal: true

module Oasis
  class TeacherCourse < OpenStruct
    def initialize(data)
      super({
        acad: data['curriculumAnneeAcademique'],
        slug: data['coursCode'],
        role: data['enseignantRole'],
        sciper: data['enseignantSciper'],
      })
    end

    def ==(other)
      sciper == other.sciper && slug == other.slug
    end
  end
end
