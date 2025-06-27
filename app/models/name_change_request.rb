# frozen_string_literal: true

class NameChangeRequest < ApplicationRecord
  belongs_to :profile
  serialize :accreditor_scipers, type: Array, coder: YAML

  belongs_to :profile

  validates :new_first, :new_last, :reason, presence: true
  validates :accreditor_scipers, presence: true
  validate :accreditors_correspondence

  def person
    profile&.person
  end

  def accreditation
    person&.accreditations&.first
  end

  def available_accreditors
    accreditation&.accreditors&.index_by(&:sciper) || {}
  end

  def selected_accreditors
    available_accreditors.slice(*accreditor_scipers)
  end

  private

  def accreditors_correspondence
    return unless selected_accreditors.empty?

    errors.add(:accreditor_scipers, :no_valid_selected)
  end
end
