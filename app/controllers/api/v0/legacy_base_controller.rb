# frozen_string_literal: true

module API
  module V0
    class LegacyBaseController < ApplicationController
      allow_unauthenticated_access
      protect_from_forgery
      before_action :check_auth

      rescue_from ActionController::BadRequest, with: :custom_bad_request

      private

      def fail
        respond_to do |format|
          format.json { render json: { errors: @errors }, status: :unprocessable_entity }
        end
      end

      # TODO: implement this. We will need an ApiAuthorisation model capable of
      #  - storing a client name (app)
      #  - storing a list of allowd IP/netmasks (serialized filed?)
      #  - storing a public_key for simple key authorisation
      #  - storing a secret_key for rapidly expiring signed requests (à la camipro photos)
      # The auth method will be chosen based on which fields are present.
      def check_auth
        Rails.logger.debug("Check Auth to be implemented")
        true
      end

      # Custom error handler for bad request parameters
      def custom_bad_request(e)
        err = e.message == "ActionController::BadRequest" ? @errors : [e.message]
        respond_to do |format|
          format.json do
            render json: { errors: err }.to_json, status: :bad_request
          end
          format.html do
            render html: err.join(", "), status: :bad_request
          end
        end
      end
    end
  end
end
