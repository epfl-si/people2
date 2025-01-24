# frozen_string_literal: true

module Work
  class Sciper < Work::Base
    self.primary_key = 'sciper'
    scope :untreated, -> { where(status: 0) }
    scope :treated, -> { where.not(status: 0) }
    scope :with_profile, -> { where(status: 3) }
    def update_status
      bb = Authorisation.botweb_for_sciper(sciper)
      if bb.empty?
        aa = Accreditation.for_sciper(sciper)
        if aa.empty?
          1
        else
          2
        end
      else
        3
      end
    end
  end
end
