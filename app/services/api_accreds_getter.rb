# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIAccredsGetter < EpflAPIService
  attr_reader :url, :id

  def initialize(sciper, baseurl = Rails.application.config_for(:epflapi).backend_url)
    @id = sciper
    @url = baseurl + "/persons/#{sciper}"
  end

  # def req_params
  #   {
  #     'authorization' => "People.key " + ENV.fetch("ATELA_KEY")
  #   }
  # end
end
