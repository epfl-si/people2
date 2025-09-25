# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class CoursesImporterJob < ApplicationJob
  queue_as :default
  # fast options delete all the records from CourseInstance and Teachership
  # hence it is good if we want to only keep only the current acad
  def perform(acad, force_refresh: false, fast: true)
    # # Fetch all course instances: each code can be given to several sections+semesters
    all_instances = OasisCourseGetter.call!(acad: acad).delete_if { |oci| oci.slug.nil? }.uniq

    # Extract the course slugs and fetch the corresponding course data
    # Some course instance from oasis have empty slug => compact
    all_slugs = all_instances.map(&:slug).uniq

    all_slugs.each_slice(100) do |slug_batch|
      existing = Course.where(acad: acad, slug: slug_batch).index_by(&:slug)
      # keep only the slugs that need to be refreshen
      slug_batch.delete_if { |slug| existing[slug].present? } unless force_refresh
      slug_batch.each do |slug|
        oc = OasisCourseGetter.call(acad: acad, code: slug)
        next if oc.blank?

        if (c = existing[slug]).present?
          c.update_from_oasis(oc)
        else
          c = Course.new_from_oasis(oc)
        end
        Rails.logger.error("Could not save invalid course #{c.inspect}: errors: #{c.errors.inspect}") unless c.save
      rescue StandardError
        Rails.logger.error("Failed to update_course. acad=#{acad}, codes=#{slug_batch.join(', ')}")
      end
    end

    course_ids_by_slug = Course.where(acad: acad).pluck(:slug, :id).to_h
    # For the moment I it easier to delete everything and reload. Later I will
    # find a less violent way of doing this. This will delete also the
    # corresponding teacherships
    if fast
      CourseInstance.delete_all
      Teachership.delete_all
    else
      CourseInstance.where(acad: acad).in_batches(of: 1000).destroy_all
    end
    all_instances.group_by(&:slug).each do |slug, ocis|
      # debugger
      cid = course_ids_by_slug[slug]
      next if cid.nil?

      CourseInstance.insert_all(ocis.map { |oci| { course_id: cid }.merge(oci.to_h) })
    end

    names_by_sciper = Work::Sciper.pluck(:sciper, :name).to_h
    # we call the ! version so that it avoid deleting old data if the request
    # to oasis fails for some reason
    all_tcs = OasisTeacherCoursesGetter.call!(acad: acad).uniq
    # Teachership.in_batches(of: 1000).delete_all

    all_tcs.group_by(&:slug).each do |slug, tcs|
      cid = course_ids_by_slug[slug]
      next if cid.nil?

      tcs_h = tcs.map do |tc|
        n = names_by_sciper[tc.sciper]
        next unless n.present? && n != "NA"

        {
          course_id: cid,
          display_name: n,
          role: tc.role,
          sciper: tc.sciper,
        }
      end.compact
      Teachership.insert_all(tcs_h)
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
