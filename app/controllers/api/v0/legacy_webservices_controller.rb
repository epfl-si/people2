# frozen_string_literal: true

module API
  module V0
    class LegacyWebservicesController < ApplicationController
      allow_unauthenticated_access
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

      # get cgi-bin/prof_awards -> /api/v0/prof_awards
      def awards
        cid = APIConfigGetter.call(res: "rights")["AAR.report.control"]["id"]
        aa = APIAuthGetter.call(authid: cid, type: 'right')
        scipers = aa.map { |a| a["persid"] }.sort.uniq
        @awards = Award.joins(:profile).where(profile: { sciper: scipers })
        respond_to do |format|
          format.json
          format.csv do
            filename = ['awards', Time.zone.today].join('_')
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = "attachment; filename=#{filename}.csv"
          end
        end
      end

      # get cgi-bin/wsgetpeople. Parameters:
      # Optional:
      #  - lang      en|fr            /^(fr|en|)$/          defaults to 'en'
      #  - position
      #  - struct
      # Mutually exclusive:
      #  - units     unit_list        /^([\w\-]*,*)*$/
      #  - scipers   scipers_list     /^(\d+,*)*$/
      #  - progcode  prog_code_list   /^(ED\w\w)$/
      #  - groups    group_list
      # Rules:
      #  - units can be multiple but only if of the same level;
      #  - struct is available only in combination with level 4 units;
      #
      # The parameters that have been actually used (see bin/wsgetpeople_stats.rb)
      # in 2024 are the following (excluding lang param):
      #       1 struct tmpl units
      #       1 position
      #      17 none
      #      55 position progcode
      #    4327 groups position
      #   28004 position scipers <- should we support this although it does not make sense ?
      #   37543 position struct units
      #   68874 groups
      #  102652 progcode
      #  328891 struct units
      # 1108122 position units
      # 1490424 units
      # 3010329 scipers
      # TODO: most of what is done here is just passing the request to api.
      #       we should probably send people directly to api instead.
      POSITION_RE = /^(!?[[:alpha:]]+)( (or|and) (!?[[:alpha:]]+))*$/
      def people
        @errors = []
        pp = people_params

        # ----------------------------------------------------- input validation
        # Optional parameters: position, struct, lang
        if pp['lang'].present?
          lang = pp['lang']
          if Rails.configuration.available_languages.include?(lang)
            @lang = lang
          else
            @errors << "invalid language #{lang}"
          end
        end
        @lang ||= Rails.configuration.i18n.default_locale

        if pp['position'].present?
          f = PositionFilter.new(pp['position'])
          if f.valid?
            @position = f
          else
            @errors << "invalid position filter #{pp['position']}"
          end
        end

        if pp['struct']
          struct = Structure.load(pp['struct'], @lang)
          if struct.present?
            @structure = struct
          else
            @errors << "invalid struct file name #{pp['struct']}"
          end
        end

        fail unless @errors.empty?

        # Mutually exclusive parameters
        mp = pp.slice("groups", "progcode", "scipers", "units").compact
        @errors << "missing mandatory parameter: groups, progcode, scipers, units" if mp.empty?
        if mp.keys.count > 1
          @errors << "only one of the following mandatory parameters can be present: groups, progcode, scipers, units"
        end
        selector = mp.keys.first
        choice = mp[selector].chomp

        send "validate_#{selector}", choice
        fail unless @errors.empty?

        case selector
        when "units"
          @units = sanitize_units(choice.split(","))
          fail unless @errors.empty?

          @persons = Person.for_units(@units)
        when "groups"
          @persons = Person.for_groups(choice.split(","))
        when "scipers"
          @persons = Person.for_scipers(choice.split(","))
        when "progcode"
          scipers = IsaThDirectorsGetter.call(progcode: choice).map { |r| r["sciper"] }
          @persons = Person.for_scipers(scipers)
        else
          raise "Invalid selector value. This should not happen as pre-validation occurs"
        end

        # filter out profiles without botweb property (Paraître dans l'annuaire Web de l'unité)
        @persons.select!(&:can_have_profile?)

        # Filter result based on the position list provided
        # I am not 100% sure yet but legacy version selects a person if
        # ANY of is positions matches (even if not in the requested unit)
        # TODO: if we could rely on the single position returned by api,
        # we could spare a lot of requests to api.
        # For some reason position filtering is admitted also in presence
        # of struct which will lead to quite empty struct... 37543 hits in 2024
        if @position
          @persons.select! do |person|
            person.match_position_filter?(@position)
          end
        end

        # TODO: check if @persons contains duplicates. Already checked for
        # units, sciper is automatic. It remains groups.

        scipers = @persons.map(&:sciper).uniq
        @profiles ||= Profile.where(sciper: scipers).index_by(&:sciper)

        respond_to do |format|
          if @errors.empty?
            if @structure.present?
              @persons.each { |person| @structure.store!(person) }
              format.json { render 'people_struct' }
            else
              format.json { render 'people_alpha' }
            end
          else
            format.json { render json: { errors: @errors }, status: :unprocessable_entity }
          end
        end
      end

      # These seams to be the data that is consumed by wordpress
      # email
      # nom, prenom
      # photo_show
      # phones taken from the unit in alpha list and from the person in struct list
      # fonction_fr, fonction_en, unit->fonction_fr, unit->fonction_en
      # unites, unit->ordre, unit->rooms
      # rooms
      # ------------------------------------------------------------------------

      private

      def fail
        respond_to do |format|
          format.json { render json: { errors: @errors }, status: :unprocessable_entity }
        end
      end

      def sanitize_scipers(scipers)
        # TODO: may be if we keep the list of valid scipers up to date we can
        #       spare some call to the api
        # okscipers = Work::Sciper.live.where(sciper: scipers).map{|s| s.sciper}
        scipers
      end

      def sanitize_units(unit_names)
        units = unit_names.uniq.map { |name| Unit.find_by(name: name) }.compact
        # levmin = units.min{|u| u.level}.level
        # levmax = units.max{|u| u.level}.level
        levmin = units.min.level
        levmax = units.max.level
        @errors << "units must be of the same level" if levmin != levmax
        @errors << "struct parameter is admitted only for leaf (level 4) units" if levmax < 4 && @structure.present?
        units
      end

      def validate_groups(groups)
        @errors << "struc can only be used in combination with units" if @structure.present?
        return if groups =~ /^([\w-]+)(,[\w-]+)*$/

        @errors << "groups should be a comma separated list of group names"
      end

      def validate_scipers(scipers)
        @errors << "struc can only be used in combination with units" if @structure.present?

        return if scipers =~ /^(\d{6})(,\d{6})*$/

        @errors << "scipers should be a comma separated list of sciper numbers"
      end

      def validate_progcode(progcode)
        @errors << "struc can only be used in combination with units" if @structure.present?
        return if progcode =~ /^(ED\w\w)$/

        @errors << "invalid format for progcode"
      end

      def validate_units(units)
        return if units =~ /^([\w-]+)(,[\w-]+)*$/

        @errors << "units should be a comma separated list of unit labels"
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
