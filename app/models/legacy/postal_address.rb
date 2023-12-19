# frozen_string_literal: true

module Legacy
  class PostalAddress < Legacy::BaseBottin
    self.table_name = 'annuaire_adrspost'
    self.primary_key = nil
    belongs_to :person, class_name: 'Person', foreign_key: 'pers_id', inverse_of: :address
    belongs_to :unit, class_name: 'Unit', inverse_of: false

    default_scope do
      where('valid_from < ? AND (valid_to > ? OR valid_to IS NULL)', DateTime.now, DateTime.now)
    end

    # def unit_id
    # 	self.unite
    # end

    def person_id
      pers_id
    end

    def sciper
      pers_id
    end

    # return all the lines in adr
    def lines
      adr.nil? ? [] : adr.split(' $ ')
    end

    # return all the lines in addr except the first one (affiliation hierarchy)
    def address_lines
      adr.nil? ? [] : adr.split(' $ ')[1..]
    end

    def full
      adr
    end

    def country
      pays
    end

    # def t_country(lang=I18n.locale)
    # 	lang.to_s == "fr" ? self.pays : self.country
    # end
  end
end
