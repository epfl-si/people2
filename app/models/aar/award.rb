# frozen_string_literal: true

module Aar
  class Award < ApplicationRecord
    self.table_name = 'awards_aar'
    belongs_to :award

    def self.for_award(a)
      r = find_or_initialize_by(award_id: a.id)
      r.assign_award(a)
      r
    end

    def assign_award(a)
      assign_attributes({
                          ordre: a.position,
                          sciper: a.sciper,
                          title: a.t_title('en'),
                          grantedby: a.issuer,
                          year: a.year,
                          category: a.t_category('en'),
                          origin: a.t_origin("en"),
                          url: a.url
                        })
    end
  end
end
