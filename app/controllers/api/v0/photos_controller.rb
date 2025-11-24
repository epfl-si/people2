# frozen_string_literal: true

module API
  module V0
    class PhotosController < LegacyBaseController
      # get cgi-bin/wsgetPhoto?app=...&sciper=...
      def show
        sciper = params[:sciper]
        profile = Profile.for_sciper(sciper)
        img = profile&.photo&.available_image
        if img.present?
          redirect_to url_for(img.variant(:large2))
        else
          redirect_to helpers.image_url('profile_image_placeholder.png')
        end
      end
    end
  end
end
