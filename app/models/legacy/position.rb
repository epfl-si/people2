# frozen_string_literal: true

module Legacy
  class Position < Legacy::BaseAccred
    self.table_name = 'positions'
    self.primary_key = 'id'
  end
end
