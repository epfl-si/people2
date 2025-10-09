# frozen_string_literal: true

class EdurlCheckerJob < ApplicationJob
  queue_as :default

  def perform
    errors = []
    Course.where(urled: nil).in_batches(of: 100) do |courses|
      Net::HTTP.start("edu.epfl.ch", 443, use_ssl: true) do |http|
        courses.each do |c|
          c.check_edu_urls(http)
          errors << c.id unless c.urled?
        end
        ActiveRecord::Base.transaction { courses.each(&:save) }
      end
    end
    # Rails.logger.info Course.find(errors).to_json
  end
end
