# frozen_string_literal: true

module Work
  class Sciper < Work::Base
    STATUS_NO_PROFILE = 0
    STATUS_WITH_LEGACY_PROFILE = 1
    STATUS_MIGRATED = 2

    self.primary_key = 'sciper'
    scope :noprofile, -> { where(status: STATUS_NO_PROFILE) }
    scope :migranda, -> { where(status: STATUS_WITH_LEGACY_PROFILE) }
    scope :migrated, -> { where(status: STATUS_MIGRATED) }
  end
end
