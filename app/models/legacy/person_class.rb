# frozen_string_literal: true

module Legacy
  class PersonClass < Legacy::BaseAccred
    self.table_name = 'classes'
    self.primary_key = 'id'
  end
end
