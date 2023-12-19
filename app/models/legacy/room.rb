# frozen_string_literal: true

module Legacy
  class Room < Legacy::BaseDinfo
    self.table_name = 'locaux'
    self.primary_key = 'room_id'
  end
end
