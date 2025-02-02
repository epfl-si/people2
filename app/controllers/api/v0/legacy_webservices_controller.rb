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
        @errors = []
        pp = people_params

        # ----------------------------------------------------- input validation
        # Optional parameters: position, struct, lang
        @options = {}
        if pp['lang']
          lang = pp['lang']
          if Rails.configuration.available_languages.include?(lang)
            @options[:lang]
          else
            @errors << "invalid language #{lang}"
          end
        end
        @options[:lang] ||= Rails.configuration.i18n.default_locale

        if pp['position']
          position = PositionFilter.new(pp['position'])
          if position.valid?
            @options[:position] = position
          else
            @errors << "invalid position filter #{pp['position']}"
          end
        end

        if pp['struct']
          structure = Structure.load(struct, lang)
          if structure.present?
            @options[:structure] = structure
          else
            @errors << "invalid struct file name #{pp['struct']}"
          end
        end

        render json: { errors: @errors }, status: :unprocessable_entity unless @errors.empty?

        # Mutually exclusive parameters
        mp = pp.slice("groups", "progcode", "scipers", "units").compact
        @errors << "missing mandatory parameter: groups, progcode, scipers, units" if mp.empty?
        if mp.keys.count > 1
          @errors << "only one of the following mandatory parameters can be present: groups, progcode, scipers, units"
        end
        selector = mp.keys.first
        choice = mp[selector]

        Rails.logger.debug("selector: #{selector}  choice: #{choice}")

        send "setup_for_#{selector}", choice

        if @errors.empty?
          render json: @output
        else
          render json: { errors: @errors }, status: :unprocessable_entity
        end
      end

      private

      def load_scipers(scipers)
        # TODO: may be if we keep the list of valid scipers up to date we can
        #       spare some call to the api
        # okscipers = Work::Sciper.live.where(sciper: scipers).map{|s| s.sciper}
        profiles = Profile.where(sciper: scipers)
        Person.for_scipers(scipers)

        @output = profiles
      end

      def setup_for_groups(groups)
        return if groups =~ /^([\w-]+)(,[\w-]+)*$/

        @errors << "groups should be a comma separated list of group names"
        nil
      end

      def setup_for_scipers(scipers)
        unless scipers =~ /^(\d{6})(,\d{6})*$/
          @errors << "scipers should be a comma separated list of sciper numbers"
          return
        end
        sa = scipers.split(",")
        load_scipers(sa)
      end

      def setup_for_progcode(progcode)
        return if progcode =~ /^(ED\w\w)$/

        @errors << "invalid format for progcode"
        nil
      end

      def setup_for_units(units)
        return if units =~ /^([\w-]+)(,[\w-]+)*$/

        @errors << "units should be a comma separated list of unit labels"
        nil
      end

      def people_params
        params.permit(
          :groups, :progcode, :scipers, :units,
          :position, :struct, :lang
        )
      end

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
