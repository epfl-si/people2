# frozen_string_literal: true

module Legacy
  class Property < Legacy::BaseAccred
    self.table_name = 'properties'
    self.primary_key = 'id'
  end
end
