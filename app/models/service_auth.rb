# frozen_string_literal: true

class ServiceAuth < ApplicationRecord
  SERVICES = {
    "v0_people_index" => "Legacy wsgetpeople",
    "v0_courses_wsgetcours" => "Legacy wsgetcours",
    "v0_courses_getcourse" => "Legacy getCourse",
    "v0_photos_show" => "Photos"
  }.freeze
  TYPES = begin
    glob = Rails.root.join('app/models/service_auth_*.rb').to_s
    Dir[glob].map do |f|
      mn = "" # "Utils::"
      bc = File.basename(f, '.rb').classify
      "#{mn}#{bc}".constantize
    end
  end

  validates :service, presence: true, inclusion: SERVICES.keys

  def self.check(service, request, params)
    # TODO: we should have user/app field for all clients so that we have nicer
    #       logs and also this `where` returns fewer lines
    where(service: service).any? { |c| c.check(request, params) }
  end

  # No auth By default, in absence of a concrete implementation
  def check
    false
  end

  def type_description
    "Base type. Should not be used directly"
  end
end
