# frozen_string_literal: true

# in the annuaire_persphones the unit_id column is not necessarily integer but
# can be "default".
module Legacy
  class PersonalPhone < Legacy::BaseBottin
    self.table_name = 'annuaire_persphones'
    self.primary_key = nil
    belongs_to :phone, class_name: 'Phone'
    belongs_to :room, class_name: 'Room'

    default_scope do
      joins(:phone).where(
        'annuaire_persphones.valid_from < ?
         AND (annuaire_persphones.valid_to > ?
         OR annuaire_persphones.valid_to IS NULL)',
        DateTime.now, DateTime.now
      )
    end

    scope :default, -> { where(unit_id: 'default') }

    def <=>(other)
      phone_order <=> other.phone_order
    end

    def hidden?
      phone_hidden
    end

    def visible?
      !phone_hidden
    end

    # default_scope {
    #   where("annuaire_persphones.valid_from < ?
    #        AND (annuaire_persphones.valid_to > ?
    #  OR annuaire_persphones.valid_to IS NULL)",
    #    DateTime.now, DateTime.now).includes(:phone)
    # }
  end
end
