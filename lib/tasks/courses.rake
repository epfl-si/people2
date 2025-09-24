# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :data do
  desc 'Reload courses: destroy and import this semester courses'
  task reload_courses: %i[nuke_courses courses] do
  end

  desc 'Destroy courses from database'
  task nuke_courses: %i[environment] do
    Course.in_batches(of: 200).destroy_all
  end

  desc 'Load courses that are not yet in the DB from Oasis '
  task courses: %i[db:migrate environment] do
    acad = Course.current_academic_year
    OasisCourseGetter.perform_now(acad)
  end

  desc 'Refresh courses with new data from Oasis'
  task refresh_courses: %i[db:migrate environment] do
    acad = Course.current_academic_year
    OasisCourseGetter.perform_now(acad, force_refresh: true)
  end
end
