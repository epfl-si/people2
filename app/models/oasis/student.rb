# frozen_string_literal: true

module Oasis
  class Student < OpenStruct
    def initialize(data)
      super({
        sciper: data['sciper'],
        active: true,
        delegate: data['delegueClasse'] == "Oui",
        level: data['niveauEtudes'],
        section: data['codeSection'],
        semester: data['semestreAcademique'],
        acad: data['anneeAcademique'],
      })
    end
  end
end
