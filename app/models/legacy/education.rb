# frozen_string_literal: true

module Legacy
  class Education < Legacy::BaseCv
    self.table_name = 'edu'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :educations
  end
end
