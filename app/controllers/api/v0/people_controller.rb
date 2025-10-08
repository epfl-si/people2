# frozen_string_literal: true

module API
  module V0
    class PeopleController < LegacyBaseController
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
      def index
        @cache_ttl = Rails.configuration.api_v0_wsgetpeople_cache
        do_people
        # if Rails.env.production?
        #   begin
        #     do_people
        #   rescue ActionController::BadRequest
        #     render json: {errors: @errors}, status: :bad_request
        #   end
        # else
        #   do_people
        # end
      end

      def do_people
        @errors = []
        extract_and_validate_params
        @force = params['refresh'].present?
        @people = load_people(@selector, @choice, force: @force)
        # Filter result based on the position list provided
        # I am not 100% sure yet but legacy version selects a person if
        # ANY of is positions matches (even if not in the requested unit)
        # TODO: if we could rely on the single position returned by api,
        # we could spare a lot of requests to api.
        # For some reason position filtering is admitted also in presence
        # of struct which will lead to quite empty struct... 37543 hits in 2024
        if @position
          @people.select! do |person|
            person.match_position_filter?(@position)
          end
        end

        raise ActionController::BadRequest unless @errors.empty?

        return if @structure.blank?

        @people.each { |person| @structure.store!(person) }
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

      # takes request parameters and instanciate them in form of instance variables
      # optional parameters: @lang, @position, @structure
      # from mutually exclusive parameters, it extracts:
      #   @selector the filter key (e.g. "units")
      #   @choice   the filter parameters (e.g. the list unit names)
      # It also builds the cache key corresponding to the request
      def extract_and_validate_params
        cache_key_parts = ["wsgetpeople_json"]

        pp = format_params

        # Optional parameters: position, struct, lang
        if pp['lang'].present?
          lang = pp['lang']
          if I18n.available_locales.include?(lang.to_sym)
            @lang = lang
          else
            @errors << "invalid language #{lang}"
          end
        end
        @lang ||= Rails.configuration.i18n.default_locale
        cache_key_parts << @lang

        if pp['position'].present?
          f = PositionFilter.new(pp['position'])
          if f.valid?
            @position = f
            cache_key_parts << pp['position']
          else
            @errors << "invalid position filter #{pp['position']}"
          end
        end

        if pp['struct']
          struct = Structure.load(pp['struct'], @lang)
          if struct.present?
            @structure = struct
            cache_key_parts << pp['struct']
          else
            @errors << "invalid struct file name #{pp['struct']}"
          end
        end

        raise ActionController::BadRequest unless @errors.empty?

        # Mutually exclusive parameters
        mp = filter_params.compact
        if mp.keys.empty?
          raise ActionController::BadRequest, "missing mandatory parameter: groups, progcode, scipers, units"
        end

        if mp.keys.count > 1
          raise ActionController::BadRequest,
                "only one of the following mandatory parameters can be present: groups, progcode, scipers, units"
        end

        @selector = mp.keys.first
        @choice = mp[@selector].chomp
        cache_key_parts << @selector
        cache_key_parts << @choice
        @cache_key = cache_key_parts.join('/')

        send "validate_#{@selector}", @choice
        Yabeda.people.wsgetpeople_calls.increment({ selector: @selector, valid: @errors.empty? ? 'yes' : 'no' }, by: 1)
        raise ActionController::BadRequest unless @errors.empty?
      end

      def sanitize_scipers(scipers)
        # TODO: may be if we keep the list of valid scipers up to date we can
        #       spare some call to the api
        # okscipers = Work::Sciper.live.where(sciper: scipers).map{|s| s.sciper}
        scipers
      end

      def sanitize_units(unit_names)
        units = unit_names.uniq.map { |name| Unit.find_by(name: name) }.compact
        if units.blank?
          @errors << "no valid unit provided"
          return []
        end

        # levmin = units.min{|u| u.level}.level
        # levmax = units.max{|u| u.level}.level
        levmin = units.min.level
        levmax = units.max.level
        @errors << "units must be of the same level" if levmin != levmax
        @errors << "struct parameter is admitted only for leaf (level 4, 5) units" if levmax < 4 && @structure.present?
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

      def load_people(selector, choice, force: false)
        if @cache_ttl.positive?
          cache_key = "wsgetpeople_people_#{selector}_#{choice}"
          Rails.cache.delete(cache_key) if force
          Rails.cache.fetch(cache_key, expires_in: @cache_ttl) do
            do_load_people(selector, choice)
          end
        else
          do_load_people(selector, choice)
        end
      end

      def do_load_people(selector, choice)
        case selector
        when "units"
          units = sanitize_units(choice.split(","))
          raise ActionController::BadRequest unless @errors.empty?

          people = BulkPerson.for_units(units)
        when "groups"
          people = BulkPerson.for_groups(choice.split(","))
        when "scipers"
          people = BulkPerson.for_scipers(choice.split(","))
        when "progcode"
          scipers = Phd.current.where(cursus: choice).distinct.pluck(:director_sciper)
          people = BulkPerson.for_scipers(scipers)
        else
          raise "Invalid selector value. This should not happen as pre-validation occurs"
        end

        # filter out profiles without botweb property (Paraître dans l'annuaire Web de l'unité)
        # people.select!(&:visible_profile?)
        # Fetch accreditations that we will need in any case so that it is cached
        # people.each(&:accreditations)
        people
      end

      def people_params
        params.permit(
          :groups, :progcode, :scipers, :units,
          :position, :struct, :lang, :refresh
        )
      end

      def filter_params
        people_params.slice(:groups, :progcode, :scipers, :units)
      end

      def format_params
        people_params.slice(:position, :struct, :lang)
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
    end
  end
end
