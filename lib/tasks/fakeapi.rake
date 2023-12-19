# frozen_string_literal: true

# Implement `./bin/rake devel:fakeapi`

require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/epfl_api_service').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s
require Rails.root.join('app/services/api_persons_getter').to_s

SCIPERS = [
  '121769',     # GC / one accred
  '116080',     # NM / one accred
  '229105',     # Edouard / prof / several accreds
  '103561' # Vincenzo / prof / several accreds
].freeze
NAMES = [
  'giovanni.cangiani'
].freeze

namespace :devel do
  desc 'Refresh fakeapi cache data'
  task fakeapi: :environment do
    Dir.chdir(Rails.root.join('tmp/fakeapi'))

    apiurl = Rails.application.config_for(:epflapi).real_backend_url

    persons_by_sciper = {}
    accreds_by_sciper = {}
    SCIPERS.each do |sciper|
      g = APIPersonsGetter.new(sciper, apiurl)
      v = g.fetch
      persons_by_sciper[sciper] = v
      g = APIAccredsGetter.new(sciper, apiurl)
      v = g.fetch
      accreds_by_sciper[sciper] = v
    end
    File.open('persons_by_sciper.json', 'w') do |f|
      f.write(persons_by_sciper.to_json)
    end
    File.open('accreds_by_sciper.json', 'w') do |f|
      f.write(accreds_by_sciper.to_json)
    end

    persons_by_name = {}
    NAMES.each do |name|
      g = APIPersonsGetter.for_email(name, apiurl)
      v = g.fetch
      persons_by_name[name] = v
    end
    File.open('persons_by_name.json', 'w') do |f|
      f.write(persons_by_name.to_json)
    end
  end
end
