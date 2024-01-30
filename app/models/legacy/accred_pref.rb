# frozen_string_literal: true

module Legacy
  class AccredPref < Legacy::BaseCv
    self.table_name = 'accreds'
    self.primary_key = nil

    belongs_to :person, class_name: "Person", foreign_key: "sciper", inverse_of: :accred_prefs

    def self.for_sciper(sciper)
      where(sciper: sciper).order(:ordre)
    end

    def order
      ordre
    end

    def unit_id
      unit
    end

    def hidden?
      # accred_show is a char in the db
      accred_show != "1"
    end

    def hidden_addr?
      # addr_hide is a char in the db
      !addr_hide.nil? && addr_hide == "1"
    end
  end
end
