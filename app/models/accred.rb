# frozen_string_literal: true

class Accred < ApplicationRecord
  attr_reader :data

  include Translatable

  translates :unit
  serialize :role, coder: Position
  belongs_to :profile, class_name: "Profile", inverse_of: :accreds

  positioned on: :profile

  validate :at_least_one_visible, on: :update

  DEFAULTS = {
    visible: true,
    visible_addr: true,
  }.freeze

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:order)
  end

  def self.for_profile!(profile)
    # TODO: add cleanup of profile.accreds that are no longer relevant or have a
    # cron job syncing so we know that all profile.accreds are probably relevant
    # and pass through Accreditation only if profile.accreds is empty.
    accreditations = Accreditation.for_profile!(profile)
    accreditations.map(&:prefs)
  end

  def hidden?
    !visible?
  end

  def hidden_addr?
    !visible_addr?
  end

  def at_least_one_visible
    return true unless visible_changed? && !visible?
    return true unless profile.accreds.where(visible: true).count < 2

    errors.add(:visible, "cannot_hide_all_accreds")
    false
  end
end
