# frozen_string_literal: true

module Legacy
  class ResearchDomain < Legacy::BaseCv
    self.table_name = 'profresearch'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: false
  end
end
