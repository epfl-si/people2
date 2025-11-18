# frozen_string_literal: true

module Work
  class Sciper < Work::Base
    # people that are not allowed to have a profile
    STATUS_NO_PROFILE = 0

    # people having a profile on the old application and hence need to be migrated
    STATUS_WITH_LEGACY_PROFILE = 1

    # people that are allowed to edit their profile but never did so that
    # they can get the default profile and forget about the legacy application.
    STATUS_MIGRATED = 2

    # New people arrived after the stop of legacy (records added by Person.find)
    STATUS_AUTOMATIC = 4

    self.primary_key = 'sciper'
    # people @EPFL without botweb property = not allowed to have a profile
    scope :noprofile, -> { where(status: STATUS_NO_PROFILE) }
    # migranda + migrated = all people that can have a profile
    # migrated includes also people that never created a legacy profile
    scope :migranda, -> { where(status: STATUS_WITH_LEGACY_PROFILE) }
    scope :migrated, -> { where(status: STATUS_MIGRATED) }

    def display_name
      name
    end

    # TODO: check if this is always the case as there might be issues with people
    #       changing name, with modified usual names etc.
    # TODO: The hack for non-standard e-mail exposes sciper address but the page
    #       is only reacheable using the sciper...
    def slug
      if email =~ /^[a-z-]+\.[a-z-]+/i
        email.gsub(/@.*$/, '')
      else
        sciper
      end
    end
  end
end
