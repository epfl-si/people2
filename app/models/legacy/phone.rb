# frozen_string_literal: true

module Legacy
  class Phone < Legacy::BaseBottin
    self.table_name = 'annuaire_phones'
    self.primary_key = 'phone_id'

    default_scope do
      where('annuaire_phones.valid_from < ?
             AND (annuaire_phones.valid_to > ?
             OR annuaire_phones.valid_to IS NULL)',
            DateTime.now, DateTime.now)
    end

    def number
      phone_nb
    end

    def category
      phone_type
    end
  end
end
