# frozen_string_literal: true

# curl --basic --user 'people:xxx' -X GET \
# 'https://api.epfl.ch/v1/authorizations?type=property&authid=gestprofil&persid=121769&status=active'
class APIAuthGetter < EpflAPIService
  attr_reader :url

  def initialize(
    sciper: nil,
    authid: 'gestprofil', # 'botweb',
    type: 'property',
    onpersid: nil,
    baseurl: Rails.application.config_for(:epflapi).backend_url
  )
    args = {
      authid: authid,
      type: type,
      status: 'active',
    }
    args[:persid] = sciper unless sciper.nil?
    args[:onpersid] = onpersid unless onpersid.nil?

    @url = URI.join(baseurl, "v1/authorizations")
    @url.query = URI.encode_www_form(args)
  end

  def dofetch
    body = fetch_http
    return nil unless body

    data = JSON.parse(body)
    raise "Unexpected payload from api for url #{@url}" unless data.key?('authorizations')

    data['authorizations']
  end
end
