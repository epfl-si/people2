# frozen_string_literal: true

require 'net/http'
require 'digest'

# Remember to touch tmp/caching-dev.txt for caching to work in dev
# Fetch json from remove HTTP services
class ApplicationService
  attr_accessor :url

  def initialize(args = {}) end

  # call returns nil if no results
  def self.call(args = {})
    # debugger
    ttl = args.delete(:ttl)
    force = args.delete(:force) || false
    if ttl.present?
      new(args).fetch(ttl: ttl, force: force)
    else
      new(args).fetch(force: force)
    end
  end

  # call! raise exception in case of no results or errors
  def self.call!(args = {})
    ttl = args.delete(:ttl)
    force = args.delete(:force) || false
    if ttl.present?
      new(args).fetch!(ttl: ttl, force: force)
    else
      new(args).fetch!(force: force)
    end
  end

  def self.uncached_call(args = {})
    new(*args).dofetch
  end

  def self.clear_cache(*args)
    m = new(*args)
    Rails.cache.delete(m.cache_key)
  end

  # override to decide when to cache on a model base
  def do_cache
    true
  end

  # fetch calls dofetch which returns nil in case of no result
  def fetch(ttl: expire_in, force: false)
    # api services cache have to be enabled explicitly
    if do_cache && Rails.application.config_for(:epflapi).perform_caching
      if force
        Rails.logger.debug("Expiring cache for key: #{cache_key}")
        Rails.cache.delete(cache_key)
      end
      Rails.logger.debug("Fetching cache for key: #{cache_key}")
      res = Rails.cache.fetch(cache_key, expires_in: ttl) do
        Rails.logger.debug("Cache miss for key: #{cache_key}")
        dofetch
      end
      # we do not cache nil values because they might indicate a temporary failure
      Rails.cache.delete(cache_key) if res.nil?
      res
    else
      dofetch
    end
  end

  # fetch calls dofetch! which raise an exception in case of no result
  def fetch!(ttl: expire_in, force: false)
    if do_cache && Rails.application.config_for(:epflapi).perform_caching
      if force
        Rails.logger.debug("Expiring cache for key: #{cache_key}")
        Rails.cache.delete(cache_key)
      end
      Rails.cache.fetch(cache_key, expires_in: ttl) do
        dofetch!
      end
    else
      dofetch!
    end
  end

  # by default we assume request body is json
  # dofetch can be overridden to add custom parser of the result
  # If you just need the raw output (e.g. for html content), override as
  # def dofetch
  #   fetch_http
  # end
  def dofetch
    body = fetch_http
    if body.nil?
      nil
    else
      (@raw ? body : JSON.parse(body))
    end
  end

  def dofetch!
    Rails.logger.debug("app_service: dofetch! for url=#{@url}")
    res = dofetch
    raise ActiveRecord::RecordNotFound if res.nil?

    res
  end

  def fetch_http(uri = @url)
    Rails.logger.debug("app_service: fetching #{uri}")
    unless Rails.env.development? && Rails.application.config_for(:epflapi).offline_dev_caching
      return do_fetch_http(uri)
    end

    key = Digest::SHA256.hexdigest @url.to_s
    fpath = File.join(Rails.application.config_for(:epflapi).offline_cachedir, "#{key}.marshal")
    if File.exist?(fpath)
      Rails.logger.debug("app_service: reading offline cache file for #{@url}")
      Marshal.load(File.binread(fpath))
    else
      res = do_fetch_http(uri)
      Rails.logger.debug("app_service: saving offline cache file for #{@url}")
      File.open(fpath, 'wb') { |f| f.write(Marshal.dump(res)) }
      res
    end
  end

  def do_fetch_http(uri = @url, limit = 10)
    raise ArgumentError, 'HTTP redirect limit reached' if limit <= 0

    req = genreq(uri)

    opts = { use_ssl: true, read_timeout: 100 }
    opts.merge!(http_opts)
    response = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case response
    when Net::HTTPSuccess
      response.body.force_encoding('UTF-8')
    when Net::HTTPRedirection
      rediuri = URI.parse(response['location'])
      if rediuri.relative?
        rediuri.scheme ||= uri.scheme
        rediuri.hostname ||= uri.hostname
        rediuri = URI.parse(rediuri.to_s) unless rediuri.is_a?(URI::HTTPS)
      end
      do_fetch_http(rediuri, limit - 1)
    else
      Rails.logger.debug("app_service: request went bad (response: #{response})")
      nil
    end
  end

  def genreq(url = @url)
    Net::HTTP::Get.new(url)
  end

  def cache_key
    # TODO: url hash might not be unique if params are added to the request as
    # for example when parameters are sent with post instead of being encoded
    # in the url. Anyway this is better than the original idea that triggered
    # a bug that took me some time to find.
    uid = Digest::MD5.hexdigest(url.to_s)
    "#{self.class.name.underscore}/#{uid}"
  end

  def expire_in
    30.minutes
  end

  # Class specific request modifiers (e.g. req.basic_auth user, pass)
  def req_customize(req); end

  # extra options for Net::HTTP.start
  def http_opts
    {}
  end
end
