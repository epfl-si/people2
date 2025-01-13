# frozen_string_literal: true

class IsaCourseGetter < IsaService
  def initialize(args = {})
    sciper = args.delete(:sciper)
    raise "sciper not present in IsaTaGetter" if sciper.blank?

    # TODO: waiting for Tim to adapt the ISA api. In the mean time I use the old people
    # @url ||= Rails.application.config_for(:epflapi).isa_url + "/courses/#{@id}"
    @url = URI.parse("https://people.epfl.ch/cgi-bin/getCoursData")
    @url.query = URI.encode_www_form(sciper: sciper)
  end
end
