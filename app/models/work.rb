# frozen_string_literal: true

module Work
  class Base < ApplicationRecord
    self.abstract_class = true
    establish_connection :work
  end
end
