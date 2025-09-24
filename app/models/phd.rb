# frozen_string_literal: true

class Phd < ApplicationRecord
  establish_connection :work
  scope :current, -> { where(year: Time.zone.today.year) }
  scope :past, -> { where("year < #{Time.zone.today.year}") }
  scope :recent, -> { where("year > #{5.years.ago.year}") }

  # TODO: What if someone took 2 Phds ?
  validates :sciper, presence: true, uniqueness: true

  def doi_url
    "http://dx.doi.org/10.5075/epfl-thesis-#{thesis_number}"
  end

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
