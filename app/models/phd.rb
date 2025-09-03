# frozen_string_literal: true

class Phd < ApplicationRecord
  establish_connection :work
  # We do this more efficiently in import job
  # before_validation :ensure_name
  # def ensure_name
  #   return if name.present?
  #   begin
  #     per  = Person.find(self.sciper)
  #     self.name = per&.name&.display || "NA"
  #   rescue
  #     self.name = "NA"
  #   end
  # end
end
