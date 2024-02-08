# frozen_string_literal: true

class AccredPref < ApplicationRecord
  belongs_to :profile, class_name: "Profile", inverse_of: :accred_prefs

  DEFAULTS = {
    order: 1,
    hidden: false,
    hidden_addr: false,
  }.freeze

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:order)
  end

  def visible?
    !hidden
  end
end
