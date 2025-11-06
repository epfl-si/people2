# frozen_string_literal: true

require 'net/http'
require 'digest'
require 'ostruct'

# This is infact a temporary workaround that goes thru the legacy server
class APIPersonUpdater
  def self.call(args = {})
    new.call(args)
  end

  def call(indata)
    data = indata.slice(:sciper, :firstname, :lastname, :gender)
    sciper = data[:sciper] || data['sciper']
    raise "Missing mandatory parameter sciper" unless data.key?(:sciper)

    params = {}
    params["genderUsual"] = data[:gender] if data.key?(:gender)
    params["lastnameUsual"] = data[:lastname] if data.key?(:lastname)
    params["firstnameUsual"] = data[:firstname] if data.key?(:firstname)

    patch(sciper, params) unless params.empty?
  end

  private

  def patch(sciper, params)
    # Rails.logger.debug("%%%%%%%%% API PATCH for #{sciper} with params=#{params.inspect}")
    # return true

    baseurl = Rails.application.config_for(:epflapi).backend_url
    uri = URI.join(baseurl, "persons/#{sciper}")

    cfg = Rails.application.config_for(:epflapi)
    uspa = Base64.encode64("#{cfg.username}:#{cfg.password}").chomp
    auth = "Basic #{uspa}"

    req = Net::HTTP::Patch.new(uri)
    req["Authorization"] = auth
    req.content_type = 'application/json'
    req.body = params.to_json
    opts = { use_ssl: true, read_timeout: 10 }
    response = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end

    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPOK)
      true
    else
      response.error!
      false
    end
  end
end
