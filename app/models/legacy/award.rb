# frozen_string_literal: true

module Legacy
  class Award < Legacy::BaseCv
    self.table_name = 'awards'

    include Ollamable
    ollamizes :title

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :awards
  end
end
