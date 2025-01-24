# frozen_string_literal: true

module Legacy
  class Achievement < Legacy::BaseCv
    self.table_name = 'achievements'

    include Ollamable
    ollamizes :description

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :achievements
  end
end
