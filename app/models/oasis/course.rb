# frozen_string_literal: true

module Oasis
  class Course < OpenStruct
    def initialize(data)
      super({
        acad: data['curriculumAnneeAcademique'],
        slug: data['codeCours'],
        lang: decode_lang(data['langueEnseignement']),
        title_en: data['nomCoursEn'],
        title_fr: data['nomCoursFr'],
        description_en: data['contenuResumeEn'],
        description_fr: data['contenuResumeFr'],
      })
    end

    def slug_prefix
      slug.split("-").first
    end

    def decode_lang(l)
      l == 'AN' ? 'EN' : 'FR'
    end

    def ==(other)
      @code == other.code && @acad == other.acad
    end
  end
end
