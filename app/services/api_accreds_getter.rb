# frozen_string_literal: true

# TODO: ask IAM for missing class delegate (done, waiting)

class APIAccredsGetter < EpflAPIService
  attr_reader :url

  private_class_method :new

  def initialize(url, single: true)
    @url = url
    @single = single
  end

  def self.for_sciper(sciper, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/accreds")
    url.query = URI.encode_www_form(persid: sciper)
    new(url)
  end

  def self.for_sciper_and_unit(sciper, unit_id, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/accreds")
    url.query = URI.encode_www_form(persid: sciper, unitid: unit_id)
    new(url)
  end

  def self.for_status(status_id, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/accreds")
    url.query = URI.encode_www_form(statusid: status_id)
    new(url)
  end

  def dofetch
    body = fetch_http
    return [] unless body

    data = JSON.parse(body)
    return [] unless data.key? 'accreds'

    data['accreds']
  end
end
