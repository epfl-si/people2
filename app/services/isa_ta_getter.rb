# frozen_string_literal: true

# curl https://isa.epfl.ch/services/teachers/103561 | jq
# ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561'" | jq
class IsaTaGetter < IsaService
  def initialize(data = {})
    sciper = data.delete(:sciper)
    raise "sciper not present in IsaTaGetter" if sciper.blank?

    @url = URI.join(Rails.application.config_for(:epflapi).isa_url, "/services/teachers/#{sciper}")
  end

  def expire_in
    24.hours
  end
end
