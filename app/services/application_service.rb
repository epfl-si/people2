# frozen_string_literal: true

require 'digest'

# Remember to touch tmp/caching-dev.txt for caching to work in dev
# Fetch json from remove HTTP services
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).fetch
  end

  def self.uncached_call(*args, &block)
    new(*args, &block).dofetch
  end

  def fetch
    if Rails.application.config_for(:epflapi).disable_cache
      dofetch
    else
      Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
        dofetch
      end
    end
  end

  def fetch!
    if Rails.application.config_for(:epflapi).disable_cache
      dofetch!
    else
      Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
        dofetch!
      end
    end
  end

  # by default we assume request body is json
  # dofetch can be overridden to add custom parser of the result
  def dofetch
    body = fetch_http
    body.nil? ? nil : JSON.parse(body)
  end

  def dofetch!
    res = dofetch
    raise "Remote resource not found. #{@url}" if res.nil?

    res
  end

  def fetch_http(uri = @url)
    Rails.logger.debug("api fetch_http / uri: #{uri}")

    req = genreq
    opts = { use_ssl: true, read_timeout: 100 }
    opts.merge!(http_opts)
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPOK
      res.body
    end
  end

  # The url method have to be overridden (usually with a getter for @url)
  # next methods are configuration and can be overridden by derived class

  def id
    nil
  end

  def genreq
    Rails.logger.debug "base genreq"
    Net::HTTP::Get.new(@url)
  end

  def cache_key
    # TODO: url hash might not be unique if params are added to the request.
    # Therefore it is safer to override cache_key or to provide an id method
    # for the moment it is responsability of the derived class
    uid = id.presence || Digest::MD5.hexdigest(url.to_s)
    "#{self.class.name.underscore}/#{uid}"
  end

  def expire_in
    24.hours
  end

  # Class specific request modifiers (e.g. req.basic_auth user, pass)
  def req_customize(req); end

  # extra options for Net::HTTP.start
  def http_opts
    {}
  end
end
