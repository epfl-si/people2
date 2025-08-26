# frozen_string_literal: true

module API
  module V0
    class PhotosController < LegacyBaseController
      # get cgi-bin/wsgetPhoto?app=...&sciper=...
      def show
        sciper = params[:sciper]
        profile = Profile.for_sciper(sciper)
        img = profile&.photo&.visible_image
        raise ActionController::RoutingError, 'Not Found' if img.blank?

        redirect_to url_for(img.variant(:large2))
      end
    end
  end
end
