# frozen_string_literal: true

# This is just to move the versions to the work database
module Work
  class Version < PaperTrail::Version
    establish_connection :work

    def changes
      @changes ||= object_changes.nil? ? {} : JSON.parse(object_changes)
    end

    def owner_name
      @owner_name ||= person_name(subject_sciper)
    end

    def author_name
      if author_sciper.nil?
        "Script or console"
      elsif author_sciper == subject_sciper
        owner_name
      else
        person_name(author_sciper)
      end
    end

    private

    def person_name(sciper)
      Person.find_by_sciper(sciper, force: false)&.name&.display
    rescue StandardError
      "Unknown"
    end
  end
end
