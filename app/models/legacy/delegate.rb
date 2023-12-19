# frozen_string_literal: true

module Legacy
  class Delegate < Legacy::BaseDinfo
    self.table_name = 'delegues'
    self.primary_key = 'sciper'

    attr_reader :full_section
  end
end
