# frozen_string_literal: true

# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class AtelaAccredsGetter < ApplicationService
  attr_reader :url, :id

  def initialize(sciper)
    @url = Rails.application.config_for(:epflapi).atela_backend_url + "/getPerson/#{sciper}"
  end

  def genreq
    req = super
    {
      'authorization' => "People.key #{Rails.application.config_for(:epflapi).atela_key}"
    }.each { |k, v| req[k] = v }
    req
  end
end
