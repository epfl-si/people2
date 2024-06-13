# frozen_string_literal: true

class Accred < ApplicationRecord
  attr_reader :data

  belongs_to :profile, class_name: "Profile", inverse_of: :accreds

  positioned on: :profile

  validate :at_least_one_visible, on: :update

  DEFAULTS = {
    hidden: false,
    hidden_addr: false,
  }.freeze

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:order)
  end

  def visible?
    !hidden
  end

  def data=(accreditation)
    raise 'Unexpected class' unless p.is_a?(Accreditation)

    @data = accreditation
  end

  def at_least_one_visible
    return true unless hidden_changed? && hidden

    return unless profile.accreds.where(hidden: false).count < 2

    errors.add(:hidden, "cannot_hide_all_accreds")
  end
end
