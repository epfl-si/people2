# frozen_string_literal: true

module Aar
  class Accred < ApplicationRecord
    self.table_name = 'accreds_aar'
    belongs_to :accred

    def self.for_accred(a)
      r = find_or_initialize_by(accred_id: a.id)
      r.assign_accred(a)
      r
    end

    def assign_accred(a)
      assign_attributes({
                          accred_id: a.id,
                          sciper: a.sciper,
                          unit: a.unit_id,
                          accred_show: a.public?,
                          ordre: a.position
                        })
    end
  end
end
