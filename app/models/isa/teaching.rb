# frozen_string_literal: true

# TODO: this is for the tmp version coming from the old people
module Isa
  class Lecture
    attr_reader :code, :description, :lang, :section, :semester, :title, :url, :year

    def initialize(c)
      @course_id = c['I_MATIERE']
      @year = c['C_PERACAD']
      @code = c['C_CODECOURS']
      @description = c['X_OBJECTIFS']
      @lang = c['C_LANGUEENS']
      @loc = c['C_LANGUE']
      @section = c['C_PEDAGO']
      @semester = c['C_SEMESTRE']
      @title = c['X_MATIERE']
      @url = c['X_URL']
    end
  end

  # class CourseGroup
  #   include Translatable
  #   translates :title, :description

  #   def initialize(c)
  #     @loc = c.loc
  #     instance_variable_set("@title_#{c.loc}", c.title) unless instance_variable_get("@title_#{c.loc}")
  #     unless instance_variable_get("@description_#{c.loc}")
  #       instance_variable_set("@description_#{c.loc}",
  #                             c.description)
  #     end
  #     @lang = c.lang
  #     @urls = {
  #       [c.section, c.semester] => @url
  #     }
  #   end

  #   def add(c)
  #     return false unless c.title == @title && c.loc == @loc
  #     @description ||= c.description

  #   end
  # end
end

module Isa
  class Thesis
    attr_reader :exmat_date, :number, :first_name, :last_name, :full_name, :sciper

    def initialize(t)
      # @data=t
      d = t['dateExmatriculation']
      n = t['thesis']['number']
      @exmat_date = d.present? ? Date.strptime(d, '%d.%m.%Y') : nil
      @number = n.presence

      @first_name = t['doctorant']['firstName']
      @last_name = t['doctorant']['lastName']
      @full_name = t['doctorant']['fullName'] || "#{@first_name} #{@last_name}"
      @sciper = t['doctorant']['sciper']
    end

    def past?
      @exmat_date.present? and @exmat_date < Time.zone.today
    end

    def current?
      !past?
    end
  end
end

# Isa::Teaching
# Merge all teaching data.
#   @ta       generic teaching activities (in which sections is teaching etc.)
#   @phd      the list of past and present PhD students
#   @courses  the list of courses given.
module Isa
  class Teaching
    attr_reader :ta, :sciper, :phd, :lectures

    def initialize(sciper)
      @sciper = sciper
      @ta = load_ta(sciper)
      @phd = load_phd(sciper)
      @lectures = load_lectures(sciper)
      return unless @ta.nil? || @phd.nil?

      Rails.logger.warn("failed to fetch ISA teaching data for sciper #{sciper}")
    end

    def courses
      @lectures.uniq(&:title)
    end

    def grouped_courses
      @lectures.uniq { |c| c.course_id == 3_659_768_971 }
    end

    def primary_teaching
      @primary_teaching ||= if @ta.present? && @ta['ensignementSecPrimaire'].present?
                              @ta['ensignementSecPrimaire'].reject do |e|
                                ee = e['dateFinValidite']
                                ee.present? && Date.parse(ee) < Time.zone.today
                              end
                            else
                              []
                            end
    end

    def secondary_teaching
      @secondary_teaching ||= if @ta.present? && @ta['enseignementSecSecondondaire'].present?
                                @ta['enseignementSecSecondondaire'].reject do |e|
                                  ee = e['dateFinValidite']
                                  ee.present? && Date.parse(ee) < Time.zone.today
                                end
                              else
                                []
                              end
    end

    def doctoral_teaching
      @doctoral_teaching ||= if @ta.present? && @ta['directorThese'].present?
                               @ta['directorThese'].reject do |e|
                                 ee = e['dateFinValidite']
                                 ee.present? && Date.parse(ee) < Time.zone.today
                               end
                             else
                               []
                             end
    end

    def primary_section_names(lang = 'en')
      primary_teaching.map { |t| (t['programme']['officialName'] || t['programme']['name'])[lang] }
    end

    def secondary_section_names(lang = 'en')
      secondary_teaching.map { |t| (t['programme']['officialName'] || t['programme']['name'])[lang] }
    end

    def bachelor_section_names(lang = 'en')
      (primary_section_names(lang) + secondary_section_names(lang)).sort.uniq
    end

    def doctoral_section_names(lang = 'en')
      doctoral_teaching.map { |t| (t['programme']['officialName'] || t['programme']['name'])[lang] }
    end

    def phd_directorships
      @phd_directorships ||= if @ta.present? && @ta['directorThese'].present?
                               @ta['directorThese'].reject do |e|
                                 ee = e['dateFinValidite']
                                 ee.present? && Date.parse(ee) < Time.zone.today
                               end
                             else
                               []
                             end
    end

    def ta?
      primary_teaching.present? ||
        secondary_teaching.present? ||
        phd_directorships.present? ||
        past_phds.present? || current_phds.present?
      # $hasTeachingAct = 1 if defined $teachingActivity->{secondarySections};
      # $hasTeachingAct = 1 if defined $teachingActivity->{crtDoctAct}
      #                         && (scalar @{$teachingActivity->{crtDoctAct}});
      # $hasTeachingAct = 1 if defined $teachingActivity->{pastDoctAct}
      #                         && (scalar @{$teachingActivity->{pastDoctAct}});
      # $hasTeachingAct = 1 if defined $teachingActivity->{pdocsarray}
      #                         && (scalar @{$teachingActivity->{pdocsarray}});
      # $hasTeachingAct = 1 if $courses && scalar @$courses;
    end

    def phds?
      current_phds.present? or past_phds.present?
    end

    def current_phds
      return [] if @phd.blank?

      @current_phds ||= @phd.reject(&:past?)
    end

    def past_phds
      return [] if @phd.blank?

      @past_phds ||= @phd.select(&:past?)
    end

    private

    def load_lectures(sciper)
      if Rails.application.config_for(:epflapi).isa_use_oracle
        Legacy::IsaCours.for_sciper(sciper)
      else
        # TODO: this is for the tmp version coming from the old people
        data = IsaCourseGetter.call(sciper)
        return nil if data.nil?
        return nil unless data.key?('bycours')
        return nil unless data['bycours']

        res = []
        data['bycours'].each do |s|
          res.concat s['coursLoop'] if s.key?('coursLoop')
        end
        res.map { |c| Isa::Lecture.new(c) }
      end
    end

    def load_ta(sciper)
      data = IsaTaGetter.call(sciper)
      return nil if data.nil?
      return nil unless data.key?('enseignement')

      data = data['enseignement']
      ee = data['dateEnseignementFin']
      es = data['dateEnseignementDebut']
      return data if (ee.blank? || Date.parse(ee) > Time.zone.today) && (es.blank? || Date.parse(es) < Time.zone.today)

      nil
    end

    def load_phd(sciper)
      data = IsaPhdGetter.call(sciper)
      return nil if data.nil?

      data.map { |t| Isa::Thesis.new(t) }
    end
  end
end

# {
#   "person": {
#   ...
#   },
#   "role": "Enseignant",
#   "commentaire": "PATT au 01.10.2006",
#   "enseignement": {
#     "coDirectorThese": null,
#     "dateGenContract": null,
#     "enseignementFC": null,
#     "dateContractDebut": null,
#     "dateContractFin": null,
#     "dateContractRetour": null,
#     "dateEnseignementDebut": "2002-05-09",
#     "dateEnseignementFin": null,
#     "dispositionsParticulieres": null,
#     "domainesRechercheEDIC": null,
#     "domainesRechercheEDMA": null,
#     "directorThese": [
#       {
#         "programme": {
#           "name": {
#             "fr": "Physique (edoc)",
#             "en": "Physics (edoc)"
#           },
#           "code": {
#             "fr": "EDPY"
#           }
#         },
#         "dateFinValidite": null
#       },
#       {
#         "programme": {
#           "name": {
#             "fr": "Photonique (edoc)",
#             "en": "Photonics (edoc)"
#           },
#           "code": {
#             "fr": "EDPO"
#           }
#         },
#         "dateFinValidite": null
#       }
#     ],
#     "directorTheseOptions": [
#       {
#         "programme": {
#           "name": {
#             "fr": "Physique (edoc)",
#             "en": "Physics (edoc)"
#           },
#           "code": {
#             "fr": "EDPY"
#           }
#         },
#         "mailExclude": null,
#         "progExclude": null
#       },
#       {
#         "programme": {
#           "name": {
#             "fr": "Photonique (edoc)",
#             "en": "Photonics (edoc)"
#           },
#           "code": {
#             "fr": "EDPO"
#           }
#         },
#         "mailExclude": null,
#         "progExclude": null
#       }
#     ],
#     "enseignementEDOC": [
#       {
#         "programme": {
#           "name": {
#             "fr": "Physique (edoc)",
#             "en": "Physics (edoc)"
#           },
#           "code": {
#             "fr": "EDPY"
#           }
#         },
#         "dateFinValidite": null
#       }
#     ],
#     "ensignementSecPrimaire": [
#       {
#         "programme": {
#           "name": {
#             "fr": "Physique",
#             "en": "Physics"
#           },
#           "code": {
#             "fr": "PH"
#           }
#         },
#         "dateFinValidite": null
#       }
#     ],
#     "enseignementSecSecondondaire": [],
#     "enseignementFonction": [
#       {
#         "code": "PASC",
#         "name": "CODE1177251",
#         "label": "Professeur associé"
#       }
#     ]
#   }
# }
