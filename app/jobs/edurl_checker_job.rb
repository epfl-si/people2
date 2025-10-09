# frozen_string_literal: true

class EdurlCheckerJob < ApplicationJob
  queue_as :default

  def perform
    errors = []
    Course.in_batches(of: 100) do |courses|
      Net::HTTP.start("edu.epfl.ch", 443, use_ssl: true) do |http|
        courses.each do |c|
          %w[en fr].each do |l|
            uri = c.edu_url(l)

            request = Net::HTTP::Head.new(uri) # => #<Net::HTTP::Head HEAD>
            response = http.request(request)
            next if response.is_a?(Net::HTTPSuccess)

            t = c.t_title(l)
            errors << {
              id: c.id,
              slug: c.slug,
              locale: l,
              title: t,
              url: uri
            }
            # Rails.logger.debug "ERR #{c.id}/#{c.slug} '#{t}' -> #{uri}"
          end
        end
      end
    end
    Rails.logger.info errors.to_json
  end
end
