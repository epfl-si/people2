# frozen_string_literal: true

module Legacy
  class IsaCours < Legacy::BaseIsa
    self.table_name = 'V_ISA_KIS_COURS'
    self.primary_key = nil

    def self.for_sciper(sciper)
      where(n_sciper: sciper)
    end

    def year
      c_peracad
    end

    def code
      c_codecours
    end

    def description
      x_objectifs
    end

    def lang
      c_langue
    end

    def section(lang = I18n.locale)
      IsaCode.t_pedago(c_section, lang)
    end

    def semester(lang = I18n.locale)
      I18n.translate "semester.#{c_semestre || 'undef'}", locale: lang
    end

    def title
      x_matiere
    end

    def url
      x_url
    end
  end
end
