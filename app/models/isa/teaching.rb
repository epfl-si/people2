# TODO: this is for the tmp version coming from the old people
class Isa::Course
  attr_reader :code, :description, :lang, :section, :semester, :title, :url, :year
  def initialize(c)
    @year = c['C_PERACAD']
    @code = c['C_CODECOURS']
    @description = c['X_OBJECTIFS']
    @lang = c['C_LANGUEENS']
    @section = c['C_PEDAGO']
    @semester = c['C_SEMESTRE']
    @title = c['X_MATIERE']
    @url = c['X_URL']
  end
end

class Isa::Thesis
  attr_reader :exmat_date, :number,:first_name, :last_name, :full_name, :sciper
  def initialize(t)
    # @data=t
    d = t['dateExmatriculation']
    n = t['thesis']['number']
    @exmat_date = d.present? ? Date.strptime(d, '%d.%m.%Y') : nil
    @number = n.present? ? n : nil

    @first_name = t['doctorant']['firstName']
    @last_name = t['doctorant']['lastName']
    @full_name = t['doctorant']['fullName'] || "#{@first_name} #{@last_name}" 
    @sciper = t['doctorant']['sciper']
  end

  def past?
    @exmat_date.present? and @exmat_date < Date.today
  end
  
  def current?
    not past?
  end

end

# Isa::Teaching
# Merge all teaching data.
#   @ta       generic teaching activities (in which sections is teaching etc.)
#   @phd      the list of past and present PhD students
#   @courses  the list of courses given.
class Isa::Teaching

 attr_reader :courses, :ta, :sciper, :phd

 def initialize(sciper)
    @sciper = sciper
    @ta = load_ta(sciper)
    @phd = load_phd(sciper)
    @courses = load_courses(sciper)
    if @ta.nil? or @phd.nil?
      Rails.logger.warn("failed to fetch ISA teaching data for sciper #{sciper}")
    end
  end

  def primary_teaching
    @pri_tea ||= begin
      if @ta.present? and @ta['ensignementSecPrimaire'].present?
        @ta['ensignementSecPrimaire'].select do |e|
          ee = e['dateFinValidite']
          not (ee.present? && Date.parse(ee) < Date.today )
        end
      else
        []
      end
    end
  end

  def secondary_teaching
    @sec_tea ||= begin
      if @ta.present? and @ta['enseignementSecSecondondaire'].present?
        @ta['enseignementSecSecondondaire'].select do |e|
          ee = e['dateFinValidite']
          not (ee.present? && Date.parse(ee) < Date.today )
        end
      else
        []
      end
    end
  end

  def doctoral_teaching
    @sec_tea ||= begin
      if @ta.present? and @ta['directorThese'].present?
        @ta['directorThese'].select do |e|
          ee = e['dateFinValidite']
          not (ee.present? && Date.parse(ee) < Date.today )
        end
      else
        []
      end
    end
  end

  def primary_section_names(lang='en')
    primary_teaching.map{|t| (t['programme']['officialName']||t['programme']['name'])[lang]}
  end

  def secondary_section_names(lang='en')
    secondary_teaching.map{|t| (t['programme']['officialName']||t['programme']['name'])[lang]}
  end

  def bachelor_section_names(lang='en')
    (primary_section_names(lang) + secondary_section_names(lang)).sort.uniq
  end

  def doctoral_section_names(lang='en')
    doctoral_teaching.map{|t| (t['programme']['officialName']||t['programme']['name'])[lang]}
  end

  def phd_directorships
    @phd_dir ||= begin
      if @ta.present? and @ta['directorThese'].present?
        @ta['directorThese'].select do |e|
          ee = e['dateFinValidite']
          not (ee.present? && Date.parse(ee) < Date.today )
        end
      else
        []
      end
    end
  end

  def has_ta?
    return false if @ta.nil?
    return primary_teaching.present? || 
           secondary_teaching.present? || 
           phd_directorships.present? ||
           past_phds.present? || current_phds.present?
    # $hasTeachingAct = 1 if defined $teachingActivity->{secondarySections};
    # $hasTeachingAct = 1 if defined $teachingActivity->{crtDoctAct}  && (scalar @{$teachingActivity->{crtDoctAct}}) ;
    # $hasTeachingAct = 1 if defined $teachingActivity->{pastDoctAct} && (scalar @{$teachingActivity->{pastDoctAct}}) ;
    # $hasTeachingAct = 1 if defined $teachingActivity->{pdocsarray}  && (scalar @{$teachingActivity->{pdocsarray}}) ;
    # $hasTeachingAct = 1 if $courses && scalar @$courses;
  end

  def has_phds?
    current_phds.present? or past_phds.present?
  end

  def current_phds
    return [] unless @phd.present?
    @curr_phd ||= @phd.select{|t| not t.past?}
  end

  def past_phds
    return [] unless @phd.present?
    @past_phd ||= @phd.select{|t| t.past?}
  end

 private

  def load_courses(sciper)
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
      return res.map{|c| Isa::Course.new(c)}
    end
  end

  def load_ta(sciper)
    data = IsaTaGetter.call(sciper)
    return nil if data.nil?
    return nil unless data.key?('enseignement')
    data = data['enseignement']
    ee=data['dateEnseignementFin']
    es=data['dateEnseignementDebut']
    if (!ee.present? || (ee=Date.parse(ee)) > Date.today) && (!es.present? || (es=Date.parse(es)) < Date.today)
      return data
    else
      return nil
    end 
    retrun nil unless ee.nil? 
  end

  def load_phd(sciper)
    data = IsaPhdGetter.call(sciper)
    return nil if data.nil?    
    return data.map { |t| Isa::Thesis.new(t)}
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
