# frozen_string_literal: true

class APIAccredsGetter < EpflAPIService
  attr_reader :url, :id

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
