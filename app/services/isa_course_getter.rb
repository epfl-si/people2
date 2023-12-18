class IsaCourseGetter < IsaService
  def initialize(sciper)
    # TODO: waiting for Tim to adapt the ISA api. In the mean time I use the old people
    # @url ||= Rails.application.config_for(:epflapi).isa_url + "/courses/#{@id}"
    @url = "https://people.epfl.ch/cgi-bin/getCoursData/?sciper=#{sciper}"
    @id = sciper
  end
end
