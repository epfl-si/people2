# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_base_getter').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :data do
  desc 'Refresh courses for new semester'
  task refresh_courses: %i[nuke_courses courses] do
  end

  desc 'Destroy courses from database'
  task nuke_courses: %i[db:migrate environment] do
    # File.delete('tmp/courses.json') if File.exist?('tmp/courses.json')
    puts "================== yes"
    # Teachership.in_batches(of: 1000).destroy_all
    # Course.in_batches(of: 1000).destroy_all
  end

  desc 'Download the list of ISA courses and fill the local DB as cache'
  task courses: %i[db:migrate environment] do
    courses_file = Rails.root.join("tmp/courses.json")

    if File.exist?(courses_file)
      puts "Found cached courses file at #{courses_file}, skipping fetch."
      courses = JSON.parse(File.read(courses_file))
    else
      puts "No cached courses file found, fetching data from ISA service."
      service = IsaCatalogGetter.new
      courses = service.fetch!
      File.write(courses_file, courses.to_json)
    end

    acad = Course.current_academic_year
    cdone = Course.select('code').map { |c| [c.code, true] }.to_h
    profiles_by_sciper = nil
    courses.each do |cdata|
      next if cdata['courseCode'].nil? || cdata['courseCode'] == "Unspecified Code"
      next unless cdata['curricula'].any? { |h| h['acad']['code'] == acad }
      next if cdone.key?(cdata['courseCode'])

      cc = cdata['subject']
      tt = cdata['professors']

      # In dev and during adoption we only keep the course for profile we have in the DB
      if Rails.env.development?
        # profiles_by_sciper = Profile.all.group_by(&:sciper).transform_values { |v| v[0] }
        # profile_ids_by_sciper = Profile.select(:id, :sciper).group_by(&:sciper).transform_values { |v| v.first.id }
        # TODO: check if this actually reduce memory usage
        profiles_by_sciper ||= Profile.select(:id, :sciper).all.map { |v| [v.sciper, v.id] }.to_h
        tt = tt.select { |t| profiles_by_sciper.key?(t['sciper']) }
        next if tt.empty?
      end

      # TODO: the titles are sometime provided in a single language
      course = Course.new
      course.code = cdata['courseCode']
      course.title_en = cc['name']['en']
      course.title_fr = cc['name']['fr']
      if cc['lang'].nil?
        course.language_en = 'unknown'
        course.language_fr = 'inconnu'
      else
        course.language_en = cc['lang']['en']&.downcase
        course.language_fr = cc['lang']['fr']&.downcase
      end
      course.save!

      tt.each do |t|
        sciper = t['sciper']

        Teachership.create!(
          course: course,
          sciper: sciper,
          role: t['role']['fr'],
          kind: t['type']
        )
      end
    end
  end
end
