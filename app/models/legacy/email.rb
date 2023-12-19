# frozen_string_literal: true

module Legacy
  class Email < Legacy::BaseDinfo
    self.table_name = 'emails'
    self.primary_key = 'sciper'
    belongs_to :person, class_name: 'Person', foreign_key: 'sciper', inverse_of: :email
    def address
      addrlog
    end
  end
end
