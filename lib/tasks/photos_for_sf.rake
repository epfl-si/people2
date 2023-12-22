# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/epfl_api_service').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

class Me
  trap('INT') { kill }
  trap('TERM') { kill }
  @killed = false
  def self.kill
    @killed = true
  end

  def self.killed?
    @killed
  end
end

namespace :chore do
  # Implement `./bin/rake chore:sfphotos`
  desc 'Download all the photos for personnel from the legacy server'
  task sfphotos: :environment do
    Dir.chdir(Rails.root.join('var/photos4sf'))

    pass = ENV.fetch('WSGETPHOTOPASS')
    raise "Please provide WSGETPHOTOPASS as env variable" unless pass

    batch_size = ENV.fetch('BATCHSIZE', 1000)

    if File.exist?("data.json")
      json = File.read('./data.json')
    else
      g = APIAccredsGetter.for_status(1)
      json = g.fetch
      File.write('data.json', json)
    end
    scipers = JSON.parse(json).map { |r| r['persid'] }.sort.uniq
    puts "Total number of entries: #{scipers.count}"
    already_done = Dir.glob("[0-9]*.jpg").map { |e| e.gsub(/\.jpg$/, '').to_i }.sort.uniq
    puts "Already done entries:    #{already_done.count}"
    scipers -= already_done

    empty = if File.exist?("./empty.json")
              JSON.parse(File.read("./empty.json"))
            else
              []
            end
    puts "Already seen as empty:   #{empty.count}"
    scipers -= empty
    todo = scipers.count
    puts "Remaining to do          #{todo}"

    tf = "tmp.jpg"
    http = Net::HTTP.new("people.epfl.ch", 443)
    http.use_ssl = true

    # scipers=["121769", "363674"]
    scipers.first(batch_size).each_with_index do |sciper, i|
      break if Me.killed?

      f = "#{sciper}.jpg"
      warn "#{i}/#{todo}"
      next if File.exist?(f)

      res = http.get URI.parse("https://people.epfl.ch/cgi-bin/wsgetPhoto?sciper=#{sciper}&app=#{pass}")
      if res.code == "200"
        if res.content_length.zero?
          empty << sciper
          next
        end
        File.open(tf, 'wb') do |file|
          file.write(res.body)
        end
        pipeline = ImageProcessing::MiniMagick
                   .source(File.open(tf))
                   .resize_to_limit(400, 400)
                   .strip
        begin
          pipeline.call(destination: f)
        rescue StandardError
          puts "#{sciper} conversion failed. Saving as is."
          File.rename(tf, f)
        end
      else
        puts "#{sciper} image fetch returns error code #{res.code}"
      end
    end
    puts "Saving empty list"
    File.write('./empty.json', JSON.dump(empty))
  end
end
