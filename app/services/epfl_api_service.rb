# frozen_string_literal: true

# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class EpflAPIService < ApplicationService
  def req_customize
    # @req.basic_auth Rails.application.config_for(:epflapi).username, Rails.application.config_for(:epflapi).password
    @req.basic_auth 'people', 'GialloRosso12%'
  end
end
