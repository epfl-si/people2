# frozen_string_literal: true

require 'net/http'
require 'digest'
require 'ostruct'

# This is infact a temporary workaround that goes thru the legacy server
class APIPersonUpdater
  def self.call(args = {})
    new.call(args)
  end

  def call(data)
    sciper = data['sciper'] || data[:sciper]
    raise "Missing mandatory parameter sciper" if sciper.nil?

    params = data.slice("firstnameusual", "lastnameusual", "inclusivity")

    cfg = Rails.application.config_for(:epflapi)
    uri = URI("#{cfg.legacy_url}/#{sciper}")
    # uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Put.new(uri)
    req.basic_auth(cfg.username, cfg.password)
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      true
    else
      res.error!
      false
    end
  end
end

# curl -X 'PUT' \
#   'https://api.epfl.ch/v1/persons/121769' \
#   -H 'accept: application/json' \
#   -H 'Content-Type: application/json' \
#   -H "authorization: Basic $(echo -n "people:${EPFLAPI_PASSWORD}" | base64)" \
#   -d '{
#         "birthdate": "string",
#         "firstname": "string",
#         "firstnameusual": "M",
#         "gender": "M",
#         "genderusual": "string",
#         "lastname": "string",
#         "lastnameusual": "string",
#         "sciper": 0
#       }'

# class APIPersonUpdater
#   ALL_KEYS = %w[birthdate firstname firstnameusual gender genderusual lastname lastnameusual sciper].sort
#   def call(data)
#     sciper = data['sciper']
#     raise "Missing mandatory parameter sciper" if sciper.blank?
#     raise "Incomplete data" unless data.keys.sort == ALL_KEYS

#     baseurl = Rails.application.config_for(:epflapi).backend_url
#     uri = URI.join(baseurl, "persons/#{sciper}")
#     cfg = Rails.application.config_for(:epflapi)
#     req = Net::HTTP::Put.new(url)
#     req.content_type = 'application/json'
#     req.basic_auth cfg.username, cfg.password
#     req.body = data
#     Net::HTTP.start(uri.hostname, uri.port) do |http|
#       http.request(req)
#     end
#     # TODO: check result
#   end
# end
