# frozen_string_literal: true

module Legacy
  class AccredPref < Legacy::BaseCv
    self.table_name = 'accreds'
    self.primary_key = nil

    belongs_to :person, class_name: "Person", foreign_key: "sciper", inverse_of: :accred_prefs

    def self.by_sciper(sciper)
      where(sciper:).order(:ordre)
    end

    def order
      ordre
    end

    def unit_id
      unit
    end

    def hidden?
      accred_show.zero?
    end
  end
end
