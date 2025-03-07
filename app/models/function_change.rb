# frozen_string_literal: true

class FunctionChange < ApplicationRecord
  serialize :accreditor_scipers, type: Array, coder: YAML

  validates :accreditation_id, presence: true
  validates :function, presence: true
  validates :reason, presence: true
  validates :accreditor_scipers, presence: true
  validate :accreditors_correspondence
  validates :requested_by, presence: true

  def accreditation
    raise "Accreditation not provided" if accreditation_id.blank?

    @accreditation ||= Accreditation.find(accreditation_id)

    # TODO: proper exception
  end

  def available_accreditors
    accreditation.accreditors.index_by(&:sciper)
  end

  def selected_accreditors
    available_accreditors.slice(*accreditor_scipers)
  end

  def sciper
    accreditation_id.split(":").first
  end

  def unit_id
    accreditation_id.split(":").last
  end

  def person
    Person.find(sciper)
  end

  private

  def accreditors_correspondence
    return unless selected_accreditors.empty?

    errors.add(:accreditor_scipers, "includes invalid data")
  end
end
