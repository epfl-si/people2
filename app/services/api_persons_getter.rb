# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIPersonsGetter < EpflAPIService
  attr_accessor :url, :id

  def initialize(sciper, baseurl=Rails.application.config_for(:epflapi).backend_url)
    @id=sciper
    @url = baseurl + "/persons/#{sciper}"
    puts "url=#{@url}"
  end

  def self.for_email(email, baseurl=Rails.application.config_for(:epflapi).backend_url)
    g = new(0,baseurl)
    firstname, lastname = email.gsub(/@.*$/, '').split(".")
    g.url = baseurl + "/persons?firstname=#{firstname}&lastname=#{lastname}"
    g.id = email
    g
  end
  
  # def req_params
  #   {
  #     'authorization' => "People.key " + ENV.fetch("ATELA_KEY")
  #   }
  # end
end
