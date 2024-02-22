# frozen_string_literal: true

module API
  module V0
    class LegacyController < ApplicationController
      protect_from_forgery
      before_action :check_auth

      # get cgi-bin/wsgetPhoto?app=...&sciper=...
      def photo
        sciper = params[:sciper]
        profile = Profile.for_sciper(sciper)
        if profile.present? && (photo = profile.photo).present? && photo.image.present?
          logger.debug("redirecting to #{url_for(photo.image)}")
          redirect_to url_for(photo.image)
        else
          logger.debug("not found")
          raise ActionController::RoutingError, 'Not Found'
        end
      end

      private

      # TODO: implement this. We will need an ApiAuthorisation model capable of
      #  - storing a client name (app)
      #  - storing a list of allowd IP/netmasks (serialized filed?)
      #  - storing a public_key for simple key authorisation
      #  - storing a secret_key for rapidly expiring signed requests (à la camipro photos)
      # The auth method will be chosen based on which fields are present.
      def check_auth
        true
      end
    end
  end
end
