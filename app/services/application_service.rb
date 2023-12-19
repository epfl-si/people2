# frozen_string_literal: true

require 'digest'

# Remember to touch tmp/caching-dev.txt for caching to work in dev
# Fetch json from remove HTTP services
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).cached_fetch
  end

  def self.uncached_call(*args, &block)
    new(*args, &block).fetch
  end

  def cached_fetch
    Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
      fetch
    end
  end

  # by default we assume request body is json
  def fetch
    body = fetch_http
    body.nil? ? nil : JSON.parse(body)
  end

  def fetch_http
    uri = URI.parse(url)
    @req = Net::HTTP::Get.new(uri)
    req_customize
    req_params.each { |k, v| @req[k] = v }
    opts = { use_ssl: true, read_timeout: 100 }
    opts.merge!(http_opts)
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(@req)
    end
    Rails.logger.debug "res=#{res}"
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

  def cache_key
    # TODO: url hash might not be unique if params are added to the request.
    # Therefore it is safer to override cache_key or to provide an id method
    # for the moment it is responsability of the derived class
    uid = id.presence || Digest::MD5.hexdigest(url)
    "#{self.class.name.underscore}/#{uid}"
  end

  def expire_in
    24.hours
  end

  # extra parameters for the request
  def req_params
    {}
  end

  # Class specific request modifiers (e.g. req.basic_auth user, pass)
  def req_customize(req); end

  # extra options for Net::HTTP.start
  def http_opts
    {}
  end
end
