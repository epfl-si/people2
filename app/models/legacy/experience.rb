# frozen_string_literal: true

module Legacy
  class Experience < Legacy::BaseCv
    self.table_name = 'parcours'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :experiences
  end
end
