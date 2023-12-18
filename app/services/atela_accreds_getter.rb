# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class AtelaAccredsGetter < ApplicationService
  attr_reader :url, :id

  def initialize(sciper)
    @id = sciper
    @url = Rails.application.config_for(:epflapi).atela_backend_url + "/getPerson/#{sciper}"
  end

  def req_params
    {
      'authorization' => "People.key " + Rails.application.config_for(:epflapi).atela_key
    }
  end
end
