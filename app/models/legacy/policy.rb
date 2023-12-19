# frozen_string_literal: true

module Legacy
  class Policy < Legacy::BaseAccred
    self.table_name = 'accreds_properties'
    self.primary_key = nil

    belongs_to :person, class_name: 'Person', foreign_key: 'persid', inverse_of: :policies
    belongs_to :property, class_name: 'Property', foreign_key: 'propid', inverse_of: false

    default_scope do
      where(finval: nil).includes(:property)
    end
  end
end
