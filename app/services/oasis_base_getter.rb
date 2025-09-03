# frozen_string_literal: true

# TODO: consider using ActiveResource + cached_resource

class OasisBaseGetter < ApplicationService
  def single
    false
  end

  # curl -X GET -H "Authorization: Bearer ${OASIS_BEARER}" -H "accept: application/json" $url
  def genreq(url = @url)
    Rails.logger.debug "Oasis genreq"
    Net::HTTP::Get.new(url, { "Authorization" => "Bearer #{cfg.oasis_token}" })
  end

  def cfg
    @cfg ||= Rails.application.config_for(:epflapi)
  end

  def baseurl
    cfg.oasis_baseurl
  end

  def dofetch
    body = fetch_http
    return nil unless body

    data = JSON.parse(body)
    if data.is_a?(Array)
      if single && data.count == 1
        @model.new(data.first)
      elsif single && data.empty?
        nil
      else
        data.map { |v| @model.new(v) }.uniq(&:id)
      end
    else
      @model.new(data)
    end
  end
end
