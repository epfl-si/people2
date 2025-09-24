# frozen_string_literal: true

class CoursesImporterJob < ApplicationJob
  queue_as :default
  def perform(acad, force_refresh: false)
    # Fetch all course codes for the academic year
    all_codes = OasisCourseGetter.call(acad: acad)
    all_codes.each_slice(100) do |codes|
      existing = Course.where(acad: acad, slug: codes.map(&:code)).index_by(&:code)
      codes.delete_if { |c| existing[c.code].present? } unless force_refresh

      codes.each do |oc|
        if (c = existing[oc.code]).present?
          c.update_from_oasis(oc)
        else
          c = Course.new_from_oasis(oc)
        end

        Rails.logger.error("Could not save invalid course #{c.inspect}: errors: #{c.errors.inspect}") unless c.save
      rescue StandardError
        Rails.logger.error("Failed to update_course. acad=#{acad}, codes=#{oc.code}")
      end
    end
  end
end
