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
    where(service: service).any? { |c| c.check(request, params) }
  end
end
