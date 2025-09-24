# frozen_string_literal: true

module API
  module V0
    class CoursesController < LegacyBaseController
      def index
        # if query string got format=html
        raise NotImplementedError if params["format"] != "html"

        render 'api/v0/courses/index', layout: false
      end
    end
  end
end
