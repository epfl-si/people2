# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class StudentsImporterJob < ApplicationJob
  queue_as :default

  def perform(acad: Course.current_academic_year)
    Student.delete_all
    %w[bachelor master cms].each do |level|
      recs = OasisStudentGetter.call!(acad: acad, level: level)&.map(&:to_h)
      Student.insert_all(recs)
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
