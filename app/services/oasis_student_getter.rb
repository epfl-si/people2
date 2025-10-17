# frozen_string_literal: true

class OasisStudentGetter < OasisBaseGetter
  def initialize(data = {})
    @acad = data[:acad] || Course.current_academic_year
    @level = data[:level]

    @url = URI.join(baseurl, "/etudiants/#{@level}/#{@acad}")
    @model = Oasis::Student
  end
end
