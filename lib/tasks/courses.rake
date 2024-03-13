# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/epfl_api_service').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :data do
  desc 'Download the list of ISA courses and fill the local DB as cache'
  task courses: :environment do
    service = IsaCatalogGetter.new
    courses = service.fetch!

    Teachership.destroy_all
    Course.destroy_all

    profiles_by_sciper = Profile.all.group_by(&:sciper).transform_values { |v| v[0] }

    acad = Course.current_academic_year

    courses.each do |cdata|
      next if cdata['courseCode'].nil? || cdata['courseCode'] == "Unspecified Code"
      next unless cdata['curricula'].any? { |h| h['acad']['code'] == acad }

      cc = cdata['subject']
      tt = cdata['professors']
      # In dev we only keep the course for profile we have in the DB
      next if Rails.env.development? && tt.none? { |t| profiles_by_sciper.key?(t['sciper']) }

      # TODO: the titles are sometime provided in a single language
      course = Course.new
      course.code = cdata['courseCode']
      course.title_en = cc['name']['en']
      course.title_fr = cc['name']['fr']
      course.language_en = cc['lang']['en'].downcase
      course.language_fr = cc['lang']['fr'].downcase
      course.save!

      tt.each do |t|
        sciper = t['sciper']

        if profiles_by_sciper.key?(sciper)
          profile = profiles_by_sciper[sciper]
        else
          puts "Profile for sciper #{sciper} not found: creating a new default one"
          # next if Rails.env.development?
          profile = Profile.create_with_defaults(sciper)
          profiles_by_sciper[sciper] = profile
        end
        Teachership.create!(
          course: course,
          teacher: profile,
          sciper: sciper,
          role: t['role']['fr'],
          kind: t['type']
        )
      end
    end
  end
end
