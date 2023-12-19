# frozen_string_literal: true

module Legacy
  class Status < Legacy::BaseAccred
    self.table_name = 'statuses'
    self.primary_key = 'id'
  end
end
