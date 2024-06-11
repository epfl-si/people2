# frozen_string_literal: true

if !Rails.env.production? && Rails.application.config_for(:epflapi).webmock

  require 'webmock'
  # TODO: find a clean way of doing this!!!
  # rubocop:disable Style/MixinUsage
  include WebMock::API
  # rubocop:enable Style/MixinUsage

  WebMock.enable!
  WebMock.disable_net_connect!(allow: 'camipro-photos.epfl.ch')

  jf = Rails.root.join("test/fixtures/webmocks/index.json")
  JSON.parse(File.read(jf)).each do |url, fn|
    fp = Rails.root.join("test/fixtures/webmocks/#{fn}")
    stub_request(:get, url).to_return(body: File.new(fp, status: 200))
  end
end
