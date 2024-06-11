# frozen_string_literal: true

require 'digest'
require 'yaml'
require 'json'
require 'uri'
require 'net/http'

namespace :data do
  desc 'Download data from external services urls for local dev mocking. Requires URLS WEBMOCKS APIPASS env to be set'
  task webmocks: :environment do
    hd = ENV.fetch('WEBMOCKS', Rails.root.join("test/fixtures/webmocks").to_s)
    apipass = ENV.fetch('APIPASS') { raise '!! Please provide password for api.epfl.ch as APIPASS env' }
    urls = ENV.fetch('URLS') { raise '!! Please provide path to txt file containing urls to fetch as URLS env' }
    opts = { use_ssl: true, read_timeout: 100 }
    index = {}
    File.readlines(urls, chomp: true).each do |url|
      dd = Digest::SHA256.hexdigest(url)
      fn = "#{dd}.json"
      fp = "#{hd}/#{fn}"
      index[url] = fn
      next if File.exist?(fp)

      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      req.basic_auth "people", apipass if uri.hostname == 'api.epfl.ch'

      res = Net::HTTP.start(uri.hostname, uri.port, opts) { |http| http.request(req) }
      File.open(fp, 'w') { |file| file.write(res.body) }
    end
    # File.open("#{hd}/index.yaml", 'w') { |f| f.write index.to_yaml }
    File.open("#{hd}/index.json", 'w') { |f| f.write index.to_json } # Store
  end
end
