# frozen_string_literal: true

module API
  module V0
    class CoursesController < LegacyBaseController
      layout false

      COMMA_SEP_RE = /\s*,\s*/
      CURSUS_TO_LEVEL = {
        "phd" => "Doctorat",
        "ma" => "Master",
        "ba" => "Bachelor",
        "mo" => "Mobilité",
        "ms" => "Cours de mathématiques spéciales"
      }.freeze

      # This accepts the following parameters (* => default):
      # Filters:
      #   - scipers xor (unit xor groups)   who gives the course (all comma sep lists)
      #   - section                         for which section < {AR,CDH,...,EDAM,EDAR,...,EL,ENAC,PH,...}
      #   - cursus                          for which level < {phd,ma,ba}
      #   - code                            for which ecole doctoral (must start with ED, never used in 2025)
      #   - orient                          I think this is a synonym of cursus because only have BA and MA values
      #   - sem                             semester < {ete,hiver}
      #   - langueens                       teaching language < {*en,fr}
      # Output format:
      #   - lang
      #   - detail                          level of detail < {S,M,*L}
      #   - display                         ordering < {*bycours,byprof}
      #   - format                          < {json,*html}
      # I keep the same names as in the legacy version to avoid some confusion
      def getcourse
        cp = params.permit(:lang, :scipers, :unit, :groups, :cursus, :section, :sem, :langueens, :display, :detail,
                           :format)
        @locale = cp[:lang] == "fr" ? "fr" : "en"
        scipers = cp[:scipers]&.split(COMMA_SEP_RE)&.select { |v| v =~ /[1-9][0-9]{5}/ } || []
        units = cp[:unit]&.split(COMMA_SEP_RE)
        groups = cp[:groups]&.split(COMMA_SEP_RE)

        if scipers.present? && (groups.present? || units.present?)
          raise ActionController::BadRequest, "use only one parameter : scipers | unit | groups"
        end

        if groups.present? && units.present?
          raise ActionController::BadRequest,
                "use only one parameter : unit | groups"
        end

        cursus = cp[:cursus]&.downcase || cp[:orient]&.downcase
        raise ActionController::BadRequest, "Invalid coursus" unless cursus.blank? || %w[phd ma ba mo].include?(cursus)

        level = cursus.present? ? CURSUS_TO_LEVEL[cursus] : nil

        sn = section_names(locale)
        sections = cp[:section]&.split(COMMA_SEP_RE)&.select { |s| sn.key?(s.to_sym) }
        raise ActionController::BadRequest, "Invalid sections" if cp[:section].present? && sections.blank?

        semester = cp[:sem]&.downcase
        unless semester.blank? || semester == "hiver" || semester == "ete"
          raise ActionController::BadRequest,
                "Invalid semester"
        end

        lang = cp[:langueens]&.downcase
        unless lang.blank? || lang == "en" || lang == "fr"
          raise ActionController::BadRequest,
                "Invalid teaching language langueens"
        end

        @detail = cp[:detail] || "L"
        raise ActionController::BadRequest, "Invalid display. Should be S, M, or L" unless %w[S M L].include?(@detail)

        @display = cp[:display] || "bycours"
        unless %w[bycours byprof].include?(@display)
          raise ActionController::BadRequest, "Invalid display. Should bycours or byprof"
        end

        if groups.present?
          scipers = groups.map { |g| Group.find_by(name: g) }.compact.map(&:member_scipers).flatten.uniq
        elsif units.present?
          scipers = units.map { |u| Unit.find_by(name: u) }.compact.map(&:member_scipers).flatten.uniq
        end

        # TODO: For the moment I discard the semster parameter because it does not reflect
        #      the corresponding field in the DB which has values like "Bachelor semestre 4" or "Semestre automne"
        #      may be there is a way to translate like all odd Bachelor semester are "hiver"
        # filters = { sciper: scipers, semester: semester, section: section, level: level }
        filters = { sciper: scipers, section: sections, level: level }
        @courses = Course.search(filters)

        return unless @display == "byprof"

        # get the list of scipers in order of display name
        scipers = @courses.map(&:teacherships)
                          .flatten.sort { |a, b| a.display_name <=> b.display_name }
                          .map(&:sciper)
        @courses_by_sciper = scipers.index_with { |_n| [] }
        @courses.each { |c| c.teacherships.each { |t| @courses_by_sciper[t.sciper] << c } }
        @scipers = Work::Sciper.where(sciper: scipers).index_by(&:sciper)
      end

      def wsgetcours
        # if query string got format=html
        raise NotImplementedError if params["format"].present? && params["format"] != "html"

        slug = params['code']
        raise ActionController::BadRequest, "code parameters is mandatory" if slug.blank?

        level = params['cursus'] == 'ma' ? 'master' : 'bachelor'

        filters = { level: level, slug_prefix: slug }
        @courses = Course.search(filters).sort { |a, b| a.t_title <=> b.t_title }
        # render 'api/v0/courses/wsgetcours', layout: false
      end

      private

      def section_names(lang = 'en')
        Rails.application.config_for(:dinfo_codes)[lang].fetch(:section)
      end
    end
  end
end
