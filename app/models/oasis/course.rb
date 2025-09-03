# frozen_string_literal: true

module Oasis
  class Course
    attr_reader :acad, :code, :lang, :title_en, :title_fr, :description_en, :description_fr

    def initialize(data)
      @acad = data['curriculumAnneeAcademique']
      @code = data['codeCours']
      @lang = decode_lang(data['langueEnseignement'])
      @title_en = data['nomCoursEn']
      @title_fr = data['nomCoursFr']
      @description_en = data['contenuResumeEn']
      @description_fr = data['contenuResumeFr']
    end

    def updated_course(course: nil)
      course ||= ::Course.new(acad: @acad, code: @code)
      course.assign_attributes({
                                 lang: @lang,
                                 title_en: @title_en,
                                 title_fr: @title_fr,
                                 description_en: @description_en,
                                 description_fr: @description_fr,
                               })
      course
    end

    def decode_lang(l)
      l == 'AN' ? 'EN' : 'FR'
    end

    def id
      "#{@code}_#{acad}"
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
