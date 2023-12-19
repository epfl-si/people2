# frozen_string_literal: true

module Legacy
  class Unit < Legacy::BaseDinfo
    self.table_name = 'allunits'
    self.primary_key = 'id_unite'

    # rubocop:disable Rails/HasManyOrHasOneDependent
    has_many :accreditations, class_name: 'Accreditation', foreign_key: 'unitid', inverse_of: :unit
    # rubocop:enable Rails/HasManyOrHasOneDependent

    def label(lang = 'fr')
      case lang
      when 'en'
        libelle_en
      else
        libelle
      end
    end

    def url?
      url.nil? or url.empty? ? false : true
    end
  end
end
