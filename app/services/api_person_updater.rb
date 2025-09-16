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
    unless cfg.writing_enabled
      Rails.logger.debug "Skipping write to api for person sciper=#{sciper} params: #{params.inspect}"
      return
    end

    return call_legacy(sciper, params.slice("inclusivity")) if params.key?("inclusivity")

    uri = URI("#{cfg.backend_url}/v1/persons/#{sciper}")
    req = Net::HTTP::Patch.new(uri)
    req.basic_auth(cfg.username, cfg.password)

    # For now we can only send firstnameusual and lastnameusual safely
    req.body = params.slice("firstnameusual", "lastnameusual").to_json
    req.content_type = 'application/json'
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    if res.is_a?(Net::HTTPOK) || res.is_a?(Net::HTTPSuccess)
      true
    else
      res.error!
      false
    end
  end

  # While we do not have a better option, we still use the legacy app for inclusivity
  def call_legacy(sciper, params)
    cfg = Rails.application.config_for(:epflapi)
    uri = URI("#{cfg.legacy_person_update_url}/#{sciper}")
    req = Net::HTTP::Put.new(uri)
    req.basic_auth(cfg.username, cfg.password)
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    if res.is_a?(Net::HTTPOK) || res.is_a?(Net::HTTPSuccess)
      true
    else
      res.error!
      false
    end
  end
end
