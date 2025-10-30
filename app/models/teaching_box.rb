# frozen_string_literal: true

class TeachingBox
  attr_reader :teacher, :courses, :current_phds, :past_phds_as_director, :past_phds_as_codirector

  def initialize(tea)
    @teacher = tea
    @courses = @teacher.courses.sort { |a, b| a.t_title <=> b.t_title }

    @current_phds = @teacher.current_phds
    @past_phds_as_director = @teacher.past_phds_as_director
    @past_phds_as_codirector = @teacher.past_phds_as_codirector
    @ta = [@courses, @current_phds, @past_phds_as_director, @past_phds_as_codirector].any?(&:present?)
  end

  def section
    @section ||= Section.find_by(label: "teaching")
  end

  def content?(_primary_locale = nil, _fallback_locale = nil)
    @ta.present?
  end

  def content_for?(_audience_level = 0, _primary_locale = nil, _fallback_locale = nil)
    @ta.present?
  end

  def user_destroyable?
    false
  end

  def position
    -1000
  end
end
