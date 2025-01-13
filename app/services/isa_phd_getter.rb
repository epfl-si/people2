# frozen_string_literal: true

# curl https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants | jq
# ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants'" | jq
class IsaPhdGetter < IsaService
  attr_reader :url

  def initialize(args = {})
    sciper = args.delete(:sciper)
    raise "sciper not present in IsaTaGetter" if sciper.blank?

    @url = URI.join(Rails.application.config_for(:epflapi).isa_url,
                    "/services/teachers/#{sciper}/thesis/directors/doctorants")
  end

  def expire_in
    72.hours
  end
end
