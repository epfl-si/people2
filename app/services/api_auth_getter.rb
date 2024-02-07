# frozen_string_literal: true

# curl --basic --user 'people:xxx' -X GET \
# 'https://api.epfl.ch/v1/authorizations?type=property&authid=gestprofil&persid=121769&status=active'
class APIAuthGetter < EpflAPIService
  attr_reader :url

  def initialize(
    sciper,
    authid: 'gestprofil', # 'botweb',
    type: 'property',
    baseurl: Rails.application.config_for(:epflapi).backend_url
  )
    @url = URI.join(baseurl, "v1/authorizations")
    @url.query = URI.encode_www_form(
      persid: sciper,
      type: type,
      authid: authid,
      status: 'active'
    )
  end

  def dofetch
    body = fetch_http
    return nil unless body

    data = JSON.parse(body)
    raise "Unexpected payload from api for url #{@url}" unless data.key?('authorizations')

    data['authorizations']
  end
end
