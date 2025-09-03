# frozen_string_literal: true

class OasisCourseGetter < OasisBaseGetter
  def initialize(data = {})
    @acad = data[:acad] || Course.current_academic_year
    @code = data[:code]
    if @code.present?
      @url = URI.join(baseurl, "/cours/fiche/resume/#{@acad}/#{@code}")
      @model = Oasis::Course
    else
      @url = URI.join(baseurl, "/cours/#{@acad}")
      @model = Oasis::CourseCode
    end
  end

  def do_cache
    false
  end

  def single
    @code.present?
  end
end
