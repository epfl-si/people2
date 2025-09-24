# frozen_string_literal: true

module Oasis
  class CourseCode
    attr_reader :acad, :code, :section, :level, :semester

    def initialize(data)
      @acad = data['curriculumAnneeAcademique']
      @code = data['coursCode']
      @level = data['curriculumNiveau']
      @section = data['matiereUnite']
      @semester = data['curriculumSemestre']
    end

    def course
      OasisCourseGetter.call(acad: @acad, code: @code)
    end

    def slug_prefix
      @code.split("-").first
    end

    def id
      "#{@code}_#{acad}"
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
