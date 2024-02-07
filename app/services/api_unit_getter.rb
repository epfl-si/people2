# frozen_string_literal: true

# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIUnitGetter < EpflAPIService
  attr_accessor :url

  private_class_method :new

  def initialize(url)
    @url = url
  end

  def self.find(unitid, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/units/#{unitid}")
    new(url)
  end

  def self.find!(unitid, baseurl = Rails.application.config_for(:epflapi).backend_url)
    find(unitid, baseurl).fetch
  end

  def self.fetch_units(unit_ids, baseurl = Rails.application.config_for(:epflapi).backend_url)
    unit_ids.uniq.map { |uid| find!(uid, baseurl) }
  end
end
