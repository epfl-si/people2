# frozen_string_literal: true

module Oasis
  class TeacherCourse
    attr_reader :acad, :code, :role, :sciper, :title_fr

    def initialize(data)
      @acad = data['curriculumAnneeAcademique']
      @code = data['coursCode']
      @role = data['enseignantRole']
      @sciper = data['enseignantSciper']
      @title_fr = data['coursNomFr']
    end

    def id
      "#{@code}_#{acad}"
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
