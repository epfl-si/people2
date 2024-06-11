# frozen_string_literal: true

require 'net/http'
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

  # override to decide when to cache on a model base
  def do_cache
    true
  end

  def fetch
    Rails.logger.debug("app_service: fetch for url=#{@url}")
    # api services cache have to be enabled explicitly
    if do_cache && Rails.application.config_for(:epflapi).perform_caching
      Rails.logger.debug("Fetching cache for key: #{cache_key}")
      Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
        Rails.logger.debug("Cache miss for key: #{cache_key}")
        dofetch
      end
    else
      dofetch
    end
  end

  def fetch!
    Rails.logger.debug("app_service: fetch! for url=#{@url}")
    if Rails.application.config_for(:epflapi).perform_caching
      Rails.cache.fetch(cache_key, expires_in: expire_in || 24.hours) do
        dofetch!
      end
    else
      dofetch!
    end
  end

  # by default we assume request body is json
  # dofetch can be overridden to add custom parser of the result
  def dofetch
    body = fetch_http
    body.nil? ? nil : JSON.parse(body)
  end

  def dofetch!
    Rails.logger.debug("app_service: dofetch! for url=#{@url}")
    res = dofetch
    raise "Remote resource not found. #{@url}" if res.nil?

    res
  end

  def fetch_http(uri = @url)
    Rails.logger.debug("app_service: fetching #{uri}")
    return do_fetch_http(uri) unless Rails.application.config_for(:epflapi).offline_dev_caching

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

  def do_fetch_http(uri = @url)
    Rails.logger.debug("app_service: do_fetch_http fetching #{uri}")

    req = genreq
    opts = { use_ssl: true, read_timeout: 100 }
    opts.merge!(http_opts)
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPOK
      res.body.force_encoding('UTF-8')
    end
  end

  def genreq
    Net::HTTP::Get.new(@url)
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
    24.hours
  end

  # Class specific request modifiers (e.g. req.basic_auth user, pass)
  def req_customize(req); end

  # extra options for Net::HTTP.start
  def http_opts
    {}
  end
end
