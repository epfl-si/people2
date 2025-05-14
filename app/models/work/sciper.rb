# frozen_string_literal: true

module Work
  class Sciper < Work::Base
    STATUS_UNKNOWN = 0
    STATUS_WITH_LEGACY_PROFILE = 1
    STATUS_MIGRATED = 2

    self.primary_key = 'sciper'
    scope :unknown, -> { where(status: STATUS_UNKNOWN) }
    scope :migranda, -> { where(status: STATUS_WITH_LEGACY_PROFILE) }
    scope :migrated, -> { where(status: STATUS_MIGRATED) }
  end
end
