# frozen_string_literal: true

class PersonDecacheJob < ApplicationJob
  queue_as :default

  def perform(sciper)
    # Refresh cache by force-reloading data from api (note this only concerts the /persons api)
    per = Person.find(sciper, force: true)
    Person.find(per.slug, force: true) if per.present?
  end
end
