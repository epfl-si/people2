# frozen_string_literal: true

module Legacy
  class TeachingActivity < Legacy::BaseCv
    self.table_name = 'teachingact'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :teaching_activities
  end
end
