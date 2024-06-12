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
    # input file format is just an url per line
    # line starting with # are skept (comment)
    # line starting with D will trigger deletion of the corresponding json file
    File.readlines(urls, chomp: true).each do |line|
      next if line =~ /^\s*#|^\s*$/

      puts "-- #{line}"

      if line =~ /^D /
        url = line.gsub(/^D\s+/, '').strip
        del = true
      else
        url = line.strip
        del = false
      end

      dd = Digest::SHA256.hexdigest(url)
      fn = "#{dd}.json"
      fp = "#{hd}/#{fn}"

      if del
        if File.exist?(fp)
          puts "   -> deleting #{fp}"
          File.delete(fp)
        else
          puts "   -> already absent #{fp}"
        end
        next
      end

      if File.exist?(fp)
        puts "   -> already present #{fp}"
        index[url] = fn
        next
      end

      uri = URI(url)
      puts "   -> #{fp}"
      req = Net::HTTP::Get.new(uri)
      req.basic_auth "people", apipass if uri.hostname == 'api.epfl.ch'

      res = Net::HTTP.start(uri.hostname, uri.port, opts) { |http| http.request(req) }
      puts "   -> #{res}"
      next unless res.is_a?(Net::HTTPSuccess)

      puts "   -> OK. Saving it."
      File.open(fp, 'w') { |file| file.write(res.body.force_encoding('UTF-8')) }
      index[url] = fn
    end
    # File.open("#{hd}/index.yaml", 'w') { |f| f.write index.to_yaml }
    File.open("#{hd}/index.json", 'w') { |f| f.write index.to_json } # Store
  end
end
