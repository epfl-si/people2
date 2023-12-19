# frozen_string_literal: true

module Legacy
  class Person < Legacy::BaseDinfo
    self.table_name = 'sciper'
    self.primary_key = 'sciper'

    # --------------------------------------- relationships with external models

    # rubocop:disable Rails/HasManyOrHasOneDependent
    has_one :email, class_name: 'Email', foreign_key: 'sciper', inverse_of: :person
    has_one :delegate, class_name: 'Delegate', foreign_key: 'sciper', inverse_of: false

    default_scope { includes(:email, :delegate) }

    # has_many :accreds, -> {
    #   where("#{Legacy::Accreditation.table_name}.finval IS NULL
    #      OR #{Legacy::Accreditation.table_name}.finval > ?", Date.today.strftime).
    #   order(:ordre).
    #   joins(:status).
    #   joins("LEFT OUTER JOIN classes ON classes.id = accreds.classid").
    #   joins("LEFT OUTER JOIN positions ON positions.id = accreds.posid")
    # }, :class_name => "Accreditation", :foreign_key => "persid"
    # in the end the following is faster and easier
    has_many :accreds, class_name: 'Accreditation', foreign_key: 'persid', inverse_of: :person

    has_many :address, class_name: 'PostalAddress', foreign_key: 'pers_id', inverse_of: :person
    has_many :phones, class_name: 'PersonalPhone', foreign_key: 'pers_id', inverse_of: false

    has_one  :account, class_name: 'Account', foreign_key: 'sciper', inverse_of: false

    has_many :units, class_name: 'Unit', through: :accreds, foreign_key: 'persid', source: 'unit', inverse_of: false
    has_many :positions, class_name: 'Position', through: :accreds, foreign_key: 'persid', source: 'position',
                         inverse_of: false
    has_many :policies, class_name: 'Policy', foreign_key: 'persid', inverse_of: :person
    has_many :active_policies, class_name: 'Policy', foreign_key: 'persid', inverse_of: :person
    has_many :active_properties, class_name: 'Property', through: :active_policies, foreign_key: 'persid',
                                 source: 'property', inverse_of: :person

    # rubocop:enable Rails/HasManyOrHasOneDependent
    # --------------------------------------- relationships with internal models
    has_many :accred_prefs, class_name: 'AccredPref', foreign_key: 'sciper', dependent: :destroy, inverse_of: :person
    has_many :awards, class_name: 'Award', foreign_key: 'sciper', dependent: :destroy, inverse_of: :person

    # merge accred data with data from dinfo (office, address) and people (prefs)
    def full_accreds
      @full_accreds ||= begin
        adh = address_by_unit
        phh = phones_by_unit
        prh = prefs_by_unit
        accreds.all.map do |a|
          uid = a.unit_id
          aa = a.attributes.merge({ address: adh[uid], phones: phh[uid], prefs: prh[uid] })
          Legacy::Affiliation.new(aa)
        end.sort
      end
    end

    def visible_full_accreds
      full_accreds.select(&:visible?)
    end

    def default_phone
      (phones_by_unit['default'] || visible_full_accreds).first.phone
    end

    def address_by_unit
      @address_by_unit ||= address.all.index_by(&:unit_id)
    end

    def phones_by_unit
      @phones_by_unit ||= phones.all.each_with_object({}) do |v, h|
        h[v.unit_id] ||= []
        h[v.unit_id] << v
      end
    end

    def prefs_by_unit
      @prefs_by_unit ||= accred_prefs.all.index_by(&:unit_id)
    end

    def birthday
      date_naiss
    end

    def can_edit_profile?
      # avoid doing twice the request for self.accreds if full_accreds already computed
      (@full_accreds || accreds).any?(&:can_edit_profile?) ||
        active_properties.map(&:name).include?('gestprofil')
    end

    def student?
      (@full_accreds || accreds).any?(&:student?)
    end

    # TODO: implement Rights model
    def achieving_professor?
      true
    end

    # TODO: see if it is possible to guess if person could be a teacher in order to avoid useless requests to ISA
    def possibly_teacher?
      true
    end

    def display_name
      @display_name ||= "#{prenom_usuel || prenom_acc} #{nom_usuel || nom_acc}"
    end

    def name
      prenom_usuel || prenom_acc
    end

    def surname
      nom_usuel || nom_acc
    end

    def email_address
      email.addrlog
    end

    def people_url
      nps = email.addrlog.gsub(/@.*$/, '')
      "#{Rails.configuration.official_url}/#{nps}"
    end

    def sex
      sexe
    end

    # TODO: possibly move this to a Presenter or Decorator class (see patterns)
    def gender
      sexe == 'F' ? 'female' : 'male'
    end

    def units
      accreditations.map(&:unit)
    end

    delegate :username, to: :atela

    def visible_units
      accreditations.select { |a| a.accred_show == '1' }.map(&:unit)
    end

    # dinfo
    #       dinfo.sciper.nom_acc,      dinfo.sciper.nom_usuel,
    #       dinfo.sciper.prenom_acc,   dinfo.sciper.prenom_usuel, dinfo.sciper.sexe,
    #       dinfo.allunits.sigle,      dinfo.allunits.libelle, dinfo.allunits.libelle_en,
    #       dinfo.allunits.hierarchie,
    #       dinfo.groups.gid,
    #       dinfo.annu.`local`            AS room,
    #       dinfo.annu.telephone1,
    #       dinfo.annu.telephone2,
    #       dinfo.adrspost.adresse  AS address,
    #       dinfo.adrspost.ordre    AS address_ordre,

    # accred
    #       accreds.*,
    #       statuses.`name`         AS statusname,
    #       statuses.labelfr        AS statuslabelfr,
    #       statuses.labelen        AS statuslabelen,
    #       classes.`name`          AS classname,
    #       classes.labelfr         AS classlabelfr,
    #       classes.labelen         AS classlabelen,
    #       positions.labelfr       AS poslabelfr,
    #       positions.labelen       AS poslabelen,
    #       positions.labelxx       AS poslabelxx
  end
end
