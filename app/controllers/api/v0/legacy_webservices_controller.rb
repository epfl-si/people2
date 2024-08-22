# frozen_string_literal: true

module API
  module V0
    class LegacyWebservicesController < ApplicationController
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

      # get cgi-bin/wsgetpeople. Params:
      #  optional:
      #  - lang      en|fr            /^(fr|en|)$/          defaults to 'en'
      #  - position
      #  - struct
      #  mutually exclusive:
      #  - units     unit_list        /^([\w\-]*,*)*$/
      #  - scipers   scipers_list     /^(\d+,*)*$/
      #  - progcode  prog_code_list   /^(ED\w\w)$/
      #  - groups    group_list
      # The parameters that have been actually used (see bin/wsgetpeople_stats.rb)
      # in 2024 are the following (excluding lang param):
      #       1 struct tmpl units
      #       1 position
      #      17 none
      #      55 position progcode
      #    4327 groups position
      #   28004 position scipers
      #   37543 position struct units
      #   68874 groups
      #  102652 progcode
      #  328891 struct units
      # 1108122 position units
      # 1490424 units
      # 3010329 scipers
      # TODO: most of what is done here is just passing the request to api.
      #       we should probably send people directly to api instead.
      def people
        groups   = params[:groups]
        progcode = params[:progcode]
        scipers  = params[:scipers]
        units    = params[:units]
        @errors = []
        # input validation
        if [groups, progcode, scipers, units].compact.empty?
          @errors << "missing mandatory parameter: groups, progcode, scipers, units"
        end
        if [groups, progcode, scipers, units].compact.count > 1
          @errors << "only one of the following mandatory parameters can be present: groups, progcode, scipers, units"
        end
        unless groups.nil? || groups =~ /^([\w-]*,*)*$/
          @errors << "groups should be a comma separated list of group names"
        end
        @errors << "invalid format for progcode" unless progcode.nil? || progcode =~ /^(ED\w\w)$/
        unless scipers.nil? || scipers =~ /^(\d{6},*)+$/
          @errors << "scipers should be a comma separated list of sciper numbers"
        end
        @errors << "units should be a comma separated list of unit labels" unless units.nil? || units =~ /^([\w-]*,*)*$/
        return if @errors.blank?

        render json: { errors: @errors }, status: :unprocessable_entity
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
