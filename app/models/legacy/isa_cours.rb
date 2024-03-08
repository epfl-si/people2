# frozen_string_literal: true

module Legacy
  class IsaCours < Legacy::BaseIsa
    self.table_name = 'V_ISA_KIS_COURS'
    self.primary_key = nil

    def self.for_sciper(sciper)
      where(n_sciper: sciper)
    end

    def year
      c_peracad
    end

    def code
      c_codecours
    end

    def description
      x_objectifs
    end

    def lang
      c_langueens
    end

    def loc
      c_langue
    end

    def course_id
      i_matiere
    end

    def section(lang = I18n.locale)
      IsaCode.t_pedago(c_section, lang)
    end

    def semester(lang = I18n.locale)
      I18n.translate "semester.#{c_semestre || 'undef'}", locale: lang
    end

    def title
      x_matiere
    end

    def url
      x_url
    end

    def edu_url
      "https://edu.epfl.ch/coursebook/#{c_langue}/#{x_matiere.downcase.gsub(' ', '-')}-#{c_codecours}"
    end

    private

    # the next functions are translated from Maciej edu https://github.com/epfl-si/edu-responsive
    def isa_to_cycle
      c_modelegps = csv_row.get('c_modelegps', '')
      c_pedago = csv_row.get('c_pedago', '')
      case c_modelegps
      when 'PDOC'
        return 'edoc'
      when 'MIN'
        return 'min_'
      end

      case c_pedago
      when /^BA[12]$/
        return 'bama_prop'
      when /^BA[3-6]$/
        return 'bama_cyclebachelor'
      when /^MA[1-4]$/
        return 'bama_cyclemaster'
      end
      ''
    end

    # def get_plan_label(lang = I18n.locale):
    #   key_suffix = lang == 'en' ? '_ang' : ''
    #  section = row.get('x_section' + key_suffix)
    # orientation = row.get('x_orientation' + key_suffix)
    # return orientation if orientation else section
  end
end

# require 'csv'
# dd=CSV.read('/Users/cangiani/Projects/VPSI/edu-responsive/datastore/downloads/ISA_structurePlans.2022-2023.csv')
# h=dd.first
# hh=dd[1..].map{|l| Hash[h.zip(l)]}

# hh.first
#   =>
#       {"c_modelegps"=>"FBM",
#        "x_modelegps"=>"Bachelor / Master",
#        "c_peracad"=>"2022-2023",
#        "c_semestre"=>"ETE",
#        "i_ori_sect"=>"3887376",
#        "c_section"=>"HPLANS",
#        "x_section"=>"Hors plans",
#        "x_section_off"=>"Hors plans",
#        "x_section_ang"=>"Hors plans",
#        "x_section_off_ang"=>"Hors plans",
#        "c_orientation"=>"",
#        "x_orientation"=>"",
#        "x_orientation_ang"=>"",
#        "c_pedago"=>"E",
#        "x_pedago"=>"Semestre printemps",
#        "x_pedago_ang"=>"Spring semester",
#        "c_fac"=>"",
#        "x_urlSection"=>"",
#        "x_urlPlan"=>""}

# hh[120]
#   =>
#       {"c_modelegps"=>"FBM",
#        "x_modelegps"=>"Bachelor / Master",
#        "c_peracad"=>"2022-2023",
#        "c_semestre"=>"ETE",
#        "i_ori_sect"=>"946228",
#        "c_section"=>"SC",
#        "x_section"=>"Systèmes de communication",
#        "x_section_off"=>"Section de systèmes de communication",
#        "x_section_ang"=>"Communication Systems",
#        "x_section_off_ang"=>"Section of Communication Systems",
#        "c_orientation"=>"",
#        "x_orientation"=>"",
#        "x_orientation_ang"=>"",
#        "c_pedago"=>"BA2",
#        "x_pedago"=>"Bachelor semestre 2",
#        "x_pedago_ang"=>"Bachelor semester 2",
#        "c_fac"=>"IC",
#        "x_urlSection"=>"http://ssc.epfl.ch/",
#        "x_urlPlan"=>"http://isa.epfl.ch/pe/plan_etude_bama_prop_sc_"}

# hh.map{|h| [h["c_section"], h["x_section"]]}.uniq
#    =>
# [      ["HPLANS", "Hors plans"],
#        ["ENAC", "Projeter ensemble ENAC"],
#        ["MAN", "Mise à niveau"],
#        ["CMS", "Cours de mathématiques spéciales"],
#        ["SHS", "Programme Sciences humaines et sociales"],
#        ["NX", "Neuro-X"],
#        ["MX", "Science et génie des matériaux"],
#        ["SIQ", "Science et ingénierie quantiques"],
#        ["AR", "Architecture"],
#        ["IN", "Informatique"],
#        ["MA", "Mathématiques"],
#        ["MT", "Microtechnique"],
#        ["PH", "Physique"],
#        ["CGC", "Chimie et génie chimique"],
#        ["GC", "Génie civil"],
#        ["GM", "Génie mécanique"],
#        ["EL", "Génie électrique et électronique "],
#        ["SV", "Ingénierie des sciences du vivant"],
#        ["IF", "Ingénierie financière"],
#        ["SC", "Systèmes de communication"],
#        ["DH", "Humanités digitales"],
#        ["SIE", "Sciences et ingénierie de l'environnement"],
#        ["MTE", "Management de la technologie"],
#        ["EME", "EME (EPFL Middle East)"],
#        ["MINEUR", "Mineurs"],
#        ["EDOC-GE", "Cours généraux et externes EDOC"],
#        ["EDDH", "Humanités digitales (edoc)"],
#        ["EDMS", "Approches moléculaires du vivant (edoc)"],
#        ["EDMT", "Management de la technologie (edoc)"],
#        ["EDAM", "Manufacturing (edoc)"],
#        ["EDCB", "Biologie computationnelle et quantitative (edoc)"],
#        ["EDFI", "Finance (edoc)"],
#        ["EDLS", "Learning Sciences (edoc)"],
#        ["EDAR", "Architecture et sciences de la ville (edoc)"],
#        ["EDBB", "Biotechnologie et génie biologique (edoc)"],
#        ["EDCH", "Chimie et génie chimique (edoc)"],
#        ["EDCE", "Génie civil et environnement (edoc)"],
#        ["EDEE", "Génie électrique (edoc)"],
#        ["EDIC", "Informatique et communications (edoc)"],
#        ["EDMA", "Mathématiques (edoc)"],
#        ["EDMI", "Microsystèmes et microélectronique (edoc)"],
#        ["EDME", "Mécanique (edoc)"],
#        ["EDNE", "Neurosciences (edoc)"],
#        ["EDPO", "Photonique (edoc)"],
#        ["EDPY", "Physique (edoc)"],
#        ["EDRS", "Robotique, contrôle et systèmes intelligents (edoc)"],
#        ["EDMX", "Science et génie des matériaux (edoc)"],
#        ["EDEY", "Energie (edoc)"],
#        ["", "Cours Transferable skills (edoc)"],
#        ["", "Cours blocs (edoc)"],
#        [nil, nil]]

# ssh eduprod 'cd html/studyplan ; ls -1 -r en/* fr/* | grep -v index.html'
# fr/propedeutique:
# systemes-de-communication
# sciences-et-ingenierie-de-l-environnement
# science-et-genie-des-materiaux
# programme-sciences-humaines-et-sociales
# physique
# microtechnique
# mathematiques
# ingenierie-des-sciences-du-vivant
# informatique
# genie-mecanique
# genie-electrique-et-electronique
# genie-civil
# chimie-et-genie-chimique
# architecture

# fr/mineur:
# photonics-minor
# mineur-en-territoires-en-transformation-et-climat
# mineur-en-technologies-spatiales
# mineur-en-technologies-biomedicales
# mineur-en-systems-engineering
# mineur-en-systemes-de-communication
# mineur-en-science-et-ingenierie-quantiques
# mineur-en-neuro-x
# mineur-en-management-technologie-et-entrepreneuriat
# mineur-en-ingenierie-pour-la-durabilite
# mineur-en-ingenierie-financiere
# mineur-en-informatique
# mineur-en-imaging
# mineur-en-genie-mecanique
# mineur-en-energie
# mineur-en-design-integre-architecture-et-durabilite
# mineur-en-data-science
# mineur-en-computational-biology
# mineur-en-biotechnologie
# data-and-internet-of-things-minor
# cyber-security-minor

# fr/master:
# systemes-de-communication-master
# statistique
# sciences-et-ingenierie-de-l-environnement
# science-et-ingenierie-quantiques
# science-et-ingenierie-computationnelles
# science-et-genie-des-materiaux
# robotique
# programme-sciences-humaines-et-sociales
# physique-master
# neuro-x
# microtechnique
# micro-and-nanotechnologies-for-integrated-systems
# mathematiques-master
# management-technologie-et-entrepreneuriat
# management-durable-et-technologie
# ingenierie-physique
# ingenierie-mathematique
# ingenierie-financiere
# ingenierie-des-sciences-du-vivant
# informatique-cybersecurity
# informatique
# humanites-digitales
# genie-nucleaire
# genie-mecanique
# genie-electrique-et-electronique
# genie-civil
# genie-chimique-et-biotechnologie
# energy-science-and-technology
# data-science
# chimie-moleculaire-et-biologique
# architecture

# fr/ecole_doctorale:
# transversal-skills-courses
# science-et-genie-des-materiaux
# robotique-controle-et-systemes-intelligents
# physique
# photonique
# neurosciences
# microsystemes-et-microelectronique
# mecanique
# mathematiques
# manufacturing
# management-de-la-technologie
# joint-epfl-eth-zurich-doctoral-program-in-the-learning-sciences
# informatique-et-communications
# humanites-digitales
# genie-electrique
# genie-civil-et-environnement
# finance
# energie
# cours-blocs
# chimie-et-genie-chimique
# biotechnologie-et-genie-biologique
# biologie-computationnelle-et-quantitative
# architecture-et-sciences-de-la-ville
# approches-moleculaires-du-vivant

# fr/bachelor:
# systemes-de-communication
# sciences-et-ingenierie-de-l-environnement
# science-et-genie-des-materiaux
# projeter-ensemble-enac
# programme-sciences-humaines-et-sociales
# physique
# microtechnique
# mathematiques
# ingenierie-des-sciences-du-vivant
# informatique
# genie-mecanique
# genie-electrique-et-electronique
# genie-civil
# genie-chimique
# chimie-et-genie-chimique
# chimie
# architecture

# en/propedeutics:
# physics
# microengineering
# mechanical-engineering
# mathematics
# materials-science-and-engineering
# life-sciences-engineering
# humanities-and-social-sciences-program
# environmental-sciences-and-engineering
# electrical-and-electronics-engineering
# computer-science
# communication-systems
# civil-engineering
# chemistry-and-chemical-engineering
# architecture

# en/minor:
# territories-in-transformation-and-climate-minor
# systems-engineering-minor
# space-technologies-minor
# photonics-minor
# neuro-x-minor
# minor-in-quantum-science-and-engineering
# minor-in-integrated-design-architecture-and-sustainability
# minor-in-imaging
# minor-in-engineering-for-sustainability
# mechanical-engineering-minor
# management-technology-and-entrepreneurship-minor
# financial-engineering-minor
# energy-minor
# data-science-minor
# data-and-internet-of-things-minor
# cyber-security-minor
# computer-science-minor
# computational-biology-minor
# communication-systems-minor
# biotechnology-minor
# biomedical-technologies-minor

# en/master:
# sustainable-management-and-technology
# statistics
# robotics
# quantum-science-and-engineering
# physics-master-program
# nuclear-engineering
# neuro-x-section
# molecular-biological-chemistry
# microengineering
# micro-and-nanotechnologies-for-integrated-systems
# mechanical-engineering
# mathematics-master-program
# materials-science-and-engineering
# management-technology-and-entrepreneurship
# life-sciences-engineering
# humanities-and-social-sciences-program
# financial-engineering
# environmental-sciences-and-engineering
# energy-science-and-technology
# electrical-and-electronics-engineering
# digital-humanities
# data-science
# computer-science-cybersecurity
# computer-science
# computational-science-and-engineering
# communication-systems-master-program
# civil-engineering
# chemical-engineering-and-biotechnology
# architecture
# applied-physics
# applied-mathematics

# en/doctoral_school:
# transversal-skills-courses
# robotics-control-and-intelligent-systems
# physics
# photonics
# neuroscience
# molecular-life-sciences
# microsystems-and-microelectronics
# mechanics
# mathematics
# materials-science-and-engineering
# management-of-technology
# joint-epfl-eth-zurich-doctoral-program-in-the-learning-sciences
# finance
# energy
# electrical-engineering
# digital-humanities
# computer-and-communication-sciences
# computational-and-quantitative-biology
# civil-and-environmental-engineering
# chemistry-and-chemical-engineering
# block-courses
# biotechnology-and-bioengineering
# architecture-and-sciences-of-the-city
# advanced-manufacturing

# en/bachelor:
# projeter-ensemble-enac
# physics
# microengineering
# mechanical-engineering
# mathematics
# materials-science-and-engineering
# life-sciences-engineering
# humanities-and-social-sciences-program
# environmental-sciences-and-engineering
# electrical-and-electronics-engineering
# computer-science
# communication-systems
# civil-engineering
# chemistry-and-chemical-engineering
# chemistry
# chemical-engineering
# architecture
# cangiani@GiovaMBP edu-responsive %
