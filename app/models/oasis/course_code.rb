# frozen_string_literal: true

module Oasis
  class CourseCode
    attr_reader :acad, :code

    def initialize(data)
      @acad = data['curriculumAnneeAcademique']
      @code = data['coursCode']
    end

    def course
      OasisCourseGetter.call(acad: @acad, code: @code)
    end

    def id
      "#{@code}_#{acad}"
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
