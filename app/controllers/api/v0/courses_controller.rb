# frozen_string_literal: true

module API
  module V0
    class CoursesController < LegacyBaseController
      def index
        # if query string got format=html
        raise NotImplementedError if params["format"].present && params["format"] != "html"

        slug = params['code']
        raise ArgumentError, "code parameters is mandatory" if slug.blank?

        level = params['cursus'] == 'ma' ? 'master' : 'bachelor'
        @courses = Course.where(slug_prefix: slug, level: level).sort { |a, b| a.t_title <=> b.t_title }
        render 'api/v0/courses/index', layout: false
      end
    end
  end
end
