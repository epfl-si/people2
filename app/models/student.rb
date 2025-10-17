# frozen_string_literal: true

class Student < ApplicationRecord
  establish_connection :work
  scope :delegate, -> { where(delegate: true) }

  # TODO: What if someone took 2 Phds ?
  validates :sciper, presence: true, uniqueness: true

  def self.from_oasis(oasis_student)
    new(oasis_student)
  end
end
