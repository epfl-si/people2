# frozen_string_literal: true

module Oasis
  class TeacherCourse
    attr_reader :acad, :code, :role, :sciper

    delegate :title_en, :title_fr, :t_title, :description_en, :description_fr, :t_description, :edu_url, to: :course

    def initialize(data)
      @acad = data['curriculumAnneeAcademique']
      @code = data['coursCode']
      @role = data['enseignantRole']
      @sciper = data['enseignantSciper']
    end

    def course
      @course ||= ::Course.where(slug: @code, acad: @acad).first
    end

    def id
      "#{@code}_#{acad}"
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
