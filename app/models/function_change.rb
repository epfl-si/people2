# frozen_string_literal: true

class FunctionChange < ApplicationRecord
  serialize :accreditor_scipers, type: Array, coder: YAML

  include Translatable

  validates :accreditation_id, presence: true
  validates :reason, presence: true
  validates :accreditor_scipers, presence: true
  validate :accreditors_correspondence
  validates :requested_by, presence: true

  translates :function
  validates :t_function, translatability: true

  def accreditation
    raise "Accreditation not provided" if accreditation_id.blank?

    @accreditation ||= Accreditation.find(accreditation_id)

    # TODO: proper exception
  end

  def available_accreditors
    @available_accreditors ||= begin
      # UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY UGLY
      # See https://github.com/epfl-si/people2/issues/182
      # For some reason (probably support/testing) all people belonging to a VP
      # get all the members of the ITOP-WSRV group as accreditors. This makes
      # the list of accreditors artificially long.
      # We have two options:
      #  1. memorize the list of scipers from ITOP-WSRV (configurable) and
      #     exclude just them.
      #  2. opt for a custom-configuration-less solution and take only the
      #     direct accreditors and not accreditors by inheritance and, in
      #     case there is none, we just take the full list just for safety
      all_accreds = accreditation.accreditors
      direct_accreds = all_accreds.select { |a| a["attribution"] == "role" }
      direct_accreds.empty? ? all_accreds : direct_accreds
    end
  end

  def selected_accreditors
    available_accreditors.index_by(&:sciper).slice(*accreditor_scipers)
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

    errors.add(:accreditor_scipers, :invalid)
  end
end
