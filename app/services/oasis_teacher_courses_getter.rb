# frozen_string_literal: true

class OasisTeacherCoursesGetter < OasisBaseGetter
  def initialize(data = {})
    @acad = data[:acad] || Course.current_academic_year
    # @sciper = data[:sciper] # || raise "Missing sciper for OasisTeacherCoursesGetter"
    # @url = URI.join(baseurl, "/enseignant-cours/#{@acad}?sciper-enseignant=#{@sciper}")
    @url = URI.join(baseurl, "/enseignant-cours/#{@acad}")
    @model = Oasis::TeacherCourse
  end
end
