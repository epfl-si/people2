# frozen_string_literal: true

class Accred < ApplicationRecord
  attr_reader :data
  attr_writer :accreditation

  include Translatable
  include AudienceLimitable
  audience_limit(:audience)
  audience_limit_property('address', strategy: :visibility)

  translates :unit
  serialize :role, coder: Position
  belongs_to :profile, class_name: "Profile", inverse_of: :accreds

  positioned on: :profile

  scope :visible, -> { where(visible: true) }
  scope :hidden, -> { where(visible: false) }

  validate :at_least_one_visible, on: :update

  DEFAULTS = {
    visibility: AudienceLimitable::WORLD,
    address_visibility: AudienceLimitable::WORLD,
  }.freeze

  delegate :doctoral?, :staff?, :student?, to: :accreditation

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:position)
  end

  def self.for_profile!(profile)
    # TODO: add cleanup of profile.accreds that are no longer relevant or have a
    # cron job syncing so we know that all profile.accreds are probably relevant
    # and pass through Accreditation only if profile.accreds is empty.
    accreditations = Accreditation.for_profile!(profile)
    # accreditations.map(&:prefs)
    accreditations.map do |a|
      ap = a.prefs
      ap.accreditation = a
      ap
    end
  end

  def accreditation_id
    "#{sciper}:#{unit_id}"
  end

  def accreditation
    @accreditation ||= Accreditation.find(accreditation_id)
  end

  # TODO: to be rewritten in case we want to switch to :box visibility
  def at_least_one_visible
    return true unless visibility_changed? && !visible_by?(AudienceLimitable::WORLD)
    return true unless profile.accreds.for_audience(AudienceLimitable::WORLD).count < 2

    errors.add(:visible, "errors.messages.cannot_hide_all_accreds")
    false
  end

  def short_address
    person = profile.person
    ad = person.address(unit_id)
    return nil if ad.blank?

    a.lines[1..].join(" • ")
  end

  def short_address_and_phone
    person = profile.person
    ad = person.address(unit_id)
    return nil if ad.blank?

    ph = person.phone(unit_id)
    ll = []
    ll += ad.lines[1..]
    ll << ph.number if ph.present?
    ll.join(" • ")
  end
end
