# frozen_string_literal: true

# TODO: ask IAM for missing field Matricule SAP (numsap)
# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIPersonGetter < EpflAPIService
  attr_accessor :url

  private_class_method :new

  def initialize(url, single: true)
    @url = url
    @single = single
    Rails.logger.debug "url=#{@url}"
  end

  def self.for_sciper(sciper, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/persons/#{sciper}")
    new(url)
  end

  # TODO: check if this works for everybody
  def self.for_email(email, baseurl = Rails.application.config_for(:epflapi).backend_url)
    firstname, lastname = email.gsub(/@.*$/, '').split('.')
    url = URI.join(baseurl, "v1/persons")
    url.query = URI.encode_www_form(firstname: firstname, lastname: lastname)
    new(url)
  end

  def self.for_unitid(unitid, baseurl = Rails.application.config_for(:epflapi).backend_url)
    url = URI.join(baseurl, "v1/persons")
    url.query = URI.encode_www_form(unitid: unitid)
    new(url, single: false)
  end

  def dofetch
    body = fetch_http
    return nil unless body

    data = JSON.parse(body)
    return data unless data.key?('persons')

    data = data ['persons']
    return data unless @single

    case data.count
    when 0
      nil
    when 1
      data.first
    else
      Rails.logger.warn "data for single APIPersonGetter returs multiple items: url=#{@url}"
      data.first
    end
  end
end
