# frozen_string_literal: true

class IsaCourseGetter < IsaService
  def initialize(args = {})
    sciper = args.delete(:sciper)
    raise "sciper not present in IsaTaGetter" if sciper.blank?

    # TODO: waiting for Tim to adapt the ISA api. In the mean time I use the old people
    # @url ||= Rails.application.config_for(:epflapi).isa_url + "/courses/#{@id}"
    cfg = Rails.application.config_for(:epflapi)
    @url = URI.parse(cfg.legacy_course_url)
    @url.query = URI.encode_www_form(sciper: sciper)
  end
end
