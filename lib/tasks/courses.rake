# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :data do
  desc 'Load courses that are not yet in the DB from Oasis '
  task courses: %i[db:migrate environment] do
    acad = Course.current_academic_year
    CoursesImporterJob.perform_now(acad)
  end

  desc 'Refresh courses with new data from Oasis'
  task refresh_courses: %i[db:migrate environment] do
    acad = Course.current_academic_year
    CoursesImporterJob.perform_now(acad, force_refresh: true)
  end
end
