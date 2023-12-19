# frozen_string_literal: true

module Legacy
  class Award < Legacy::BaseCv
    self.table_name = 'awards'
    belongs_to :person, class_name: 'Person', foreign_key: 'sciper', inverse_of: :awards
  end
end
