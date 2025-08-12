# frozen_string_literal: true

module Work
  class Sciper < Work::Base
    # people that are not allowed to have a profile
    STATUS_NO_PROFILE = 0
    # people having a profile on the old application
    STATUS_WITH_LEGACY_PROFILE = 1
    # people with a profile migrated from the old application
    STATUS_MIGRATED = 2
    # records added by Person.find method
    STATUS_AUTOMATIC = 4

    self.primary_key = 'sciper'
    # people @EPFL without botweb property = not allowed to have a profile
    scope :noprofile, -> { where(status: STATUS_NO_PROFILE) }
    # migranda + migrated = all people that can have a profile
    # migrated includes also people that never created a legacy profile
    scope :migranda, -> { where(status: STATUS_WITH_LEGACY_PROFILE) }
    scope :migrated, -> { where(status: STATUS_MIGRATED) }
  end
end
