# frozen_string_literal: true

class CoursesImporterJob < ApplicationJob
  queue_as :default
  def perform(acad, force_refresh: false)
    # Fetch all course codes for the academic year
    all_codes = OasisCourseGetter.call(acad: acad)
    all_codes.each_slice(10) do |codes|
      existing = Course.where(acad: acad, code: codes.map(&:code)).index_by(&:code)
      codes.delete_if { |c| existing[c.code].present? } unless force_refresh
      courses = codes.map(&:course).compact
      courses.each do |oc|
        ec = existing[oc.code]
        uc = oc.updated_course(course: ec)
        uc.save
      rescue StandardError
        clist = codes.map(&:code).join(', ')
        Rails.logger.error("Failed to update_course. acad=#{acad}, codes=#{clist}")
      end
    end
  end
end
