# frozen_string_literal: true

# TODO: consider using ActiveResource for this

class EpflAPIService < ApplicationService
  def genreq
    Rails.logger.debug "epfl api genreq"
    cfg = Rails.application.config_for(:epflapi)
    req = Net::HTTP::Get.new(@url)
    req.basic_auth cfg.username, cfg.password
    req
  end
end
