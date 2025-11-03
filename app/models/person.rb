# frozen_string_literal: true

# This class represents a person as described by api.epfl.ch
class Person
  attr_reader :account, :automap, :camipro, :data, :name

  private_class_method :new

  # has one profile

  def initialize(person)
    @data = person
    @position = @data.delete('position')
    @position = Position.new(@position) unless @position.nil?

    @account = OpenStruct.new(@data.delete('account') || {})
    @automap = OpenStruct.new(@data.delete('automap') || {})
    @camipro = OpenStruct.new(@data.delete('camipro') || {})

    # phones and addresses are hash with the unit_id as key
    @phones = @data.delete('phones')&.map { |d| Phone.new(d) }
    @addresses = @data.delete('addresses')&.map { |d| Address.new(d) }
    @rooms = @data.delete('rooms')&.map { |d| Room.new(d) }

    @name = Name.new({
                       id: sciper,
                       usual_first: @data.delete('firstnameusual'),
                       usual_last: @data.delete('lastnameusual'),
                       official_first: @data.delete('firstname'),
                       official_last: @data.delete('lastname'),
                     })
  end

  def self.find_by_sciper(sciper, force: false, auth: nil)
    data = APIPersonGetter.call!(persid: sciper, single: true, force: force, auth: auth)

    # TODO: also find_by_sciper should update Work::Sciper

    # TODO: does this make sense ? The idea is that sometime the cache is invalid (nil)
    # Therefore, we might be trying to build the object from invalid data.
    # Why not trying to refresh the cache once and try again ?
    if force
      raise ActiveRecord::RecordNotFound if data.nil?

      new(data)
    elsif data.nil?
      find_by_sciper(sciper, force: true)
    else
      begin
        new(data)
      rescue StandardError
        find_by_sciper(sciper, force: true)
      end
    end
  end

  def self.find_by_email(email, force: false)
    # This adds a request to the local DB but reduces cache memory usage
    e = "#{email}@epfl.ch"
    s = Work::Sciper.where(email: e).first
    if s.present?
      find_by_sciper(s.sciper, force: force)
    else
      data = APIPersonGetter.call!(email: e, single: false, force: force).select { |v| v['email'] == e }.first
      raise ActiveRecord::RecordNotFound if data.nil?

      r = new(data)
      s = Work::Sciper.where(sciper: r.sciper).first
      if s.present?
        s.email = r.email
        s.save
      else
        Work::Sciper.create(
          sciper: r.sciper,
          status: Work::Sciper::STATUS_AUTOMATIC,
          email: e,
          name: r.name.display
        )
      end
      r
    end
  end

  def self.find(sciper_or_email, force: false)
    if sciper_or_email.is_a?(Integer) || sciper_or_email =~ /^\d{6}$/
      find_by_sciper(sciper_or_email, force: force)
    else
      find_by_email(sciper_or_email, force: force)
    end
  end

  # TODO: keep only this version once migration is done
  # def profile!
  #   unless defined?(@profile)
  #     @profile = Profile.for_sciper(sciper)
  #     @profile = Profile.new_with_defaults(sciper) if @profile.nil? && can_have_profile?
  #   end
  #   @profile
  # end

  # return only existing profile without attempting to create a new one
  def profile
    return if defined?(@profile)

    @profile = Profile.for_sciper(sciper)
  end

  # return the existing profile or a newly created one
  def profile!
    unless defined?(@profile)
      @profile = Profile.for_sciper(sciper)
      if @profile.nil? && editable_profile?
        if Rails.configuration.enable_adoption && Work::Sciper.migranda.where(sciper: sciper).present?
          LegacyProfileImportJob.perform_now(sciper)
          @profile = Profile.for_sciper(sciper)
          @profile ||= Profile.new_with_defaults(sciper)
        else
          @profile = Profile.new_with_defaults(sciper)
        end
      end
    end
    @profile
  end

  # The right for a person to appear on people and in any other people directory
  # is determined by the botweb (id=1) property (or, better, policy) for at least one
  # if his accreditations. The property can be granted to an accreditation
  #   1. directly (join table accreds_properties),
  #   2. through its Class but, currently no class provide botweb property
  #   3. through its Status. Currently statuses with the botweb property are:
  #       1  P  Personnel
  #       2  O  Hôte
  #       3  H  Hors EPFL
  #       5  S  Etudiant
  #   4. through its unit. Currently:
  #       10000 EPFL Ecole polytechnique fédérale de Lausanne
  #       10582 EHE Entités hôtes de l'EPFL
  #       13380 DAR Domaine de la recherche
  #       14435 KUONI Kuoni Business Travel
  #       3199 ENTREPRISES Entreprises sur site
  #      unit 10000 is the whole EPFL...
  #  But we don't see anything of this because we delegate to the central API.
  def visible_profile?
    unless defined?(@visible_profile)
      @visible_profile = begin
        a = Authorisation.property_for_sciper(sciper, "botweb")
        a.any? { |d| d.active? && d.ok? }
      end
    end
    @visible_profile
  end

  # Similarly, for a person's profile to be editable, the person must have an
  # accreditation with the gestprofil (id=7) property.
  # The property can be granted to an accreditation
  #   1. directly (join table accreds_properties),
  #   2. through its Class. Currently no gestprofile is provided through class
  #   3. through its Status. Currently statuses with the gestprofil property are:
  #       1  P  Personnel
  #       5  S  Etudiant
  #   4. through its unit. Currently units providing gestprofil property are:
  #      10000 EPFL Ecole polytechnique fédérale de Lausanne
  #      14039 F-SPI Fondation SPI
  #      Again most of the people since unit 10000 is included but not the
  #      external enterprises for example.
  # Note that legacy implementation includes two extra hardcoded rights:
  #   $edit_profile = 1 if $accred->{statusid} =~ /^(1|5)$/;
  #   $edit_profile = 1 i $accred->{position}->{labelfr} eq 'Professeur honoraire';
  # The first is now included int the case 3 above;
  # The second for the moment unevitable because there is nothing like a status,
  # class, or unit that contains them all. Therefore, for the moment we have
  # to keep the terrible hardcoded filter.
  # TODO: check for a better solution to the hardcoded professor_emeritus?
  def editable_profile?
    unless defined?(@editable_profile)
      @editable_profile = begin
        a = Authorisation.property_for_sciper(sciper, "gestprofil")
        a.any? { |d| d.active? && d.ok? } || professor_emeritus?
      end
    end
    @editable_profile
  end

  def achieving_professor?
    unless defined?(@is_achieving_professor)
      aa = Authorisation.right_for_sciper(sciper, 'AAR.report.control')
      @is_achieving_professor = aa.any?(&:ok?)
    end
    @is_achieving_professor
  end

  def admin_data
    @admin_data ||= OpenStruct.new(
      @account.to_h.merge(@automap.to_h).merge(
        {
          sciper: sciper,
          sapid: @data["sapid"],
          nebis: @data["nebis"],
        }
      )
    )
  end

  def email
    @data["email"] || ""
  end

  # TODO: check if this is always the case as there might be issues with people
  #       changing name, with modified usual names etc.
  # TODO: The hack for non-standard e-mail exposes sciper address but the page
  #       is only reacheable using the sciper...
  def email_user
    if email =~ /^[a-z-]+\.[a-z-]+/i
      email.gsub(/@.*$/, '')
    else
      sciper
    end
  end

  def option(key)
    # N+1 avoided by loading all the very fiew records at once (see SpecialOption)
    @options ||= SpecialOption.for(sciper)&.index_by(&:key) || {}
    @options[key]
  end

  def sciper
    id
  end

  def public_email
    o = option(:mail)
    o.present? ? o.email : email
  end

  # --- phone

  def phones(unit_id = nil)
    if unit_id.nil?
      @phones
    else
      @phones_by_unit ||= @phones&.group_by(&:unit_id) || {}
      @phones_by_unit.key?(unit_id) ? @phones_by_unit[unit_id] : []
    end
  end

  def phone(unit_id)
    phones(unit_id).first
  end

  # Updated visible_phones method
  def visible_phones(unit_id = nil)
    phones(unit_id)&.select(&:visible?) || []
  end

  def default_phone
    @default_phone = visible_phones.min unless defined?(@default_phone)
    @default_phone
  end

  def phone_visible_by?(audience)
    p = profile!
    p.nil? ? default_phone.present? : p.phone_visible_by?(audience)
  end

  # --- address

  def addresses(unit_id = nil)
    if unit_id.nil?
      @addresses
    else
      @addresses_by_unit ||= @addresses&.group_by(&:unit_id) || {}
      @addresses_by_unit.key?(unit_id) ? @addresses_by_unit[unit_id] : []
    end
  end

  def visible_addresses(unit_id = nil)
    # TODO: address does not have the visible property while this is supposed
    # to be set in Accred.
    # addresses(unit_id)&.select(&:visible?) || []
    addresses(unit_id)
  end

  def address(unit_id = nil)
    visible_addresses(unit_id).first
  end

  def default_address
    unless defined?(@default_address)
      # TODO: we should take into account the additional ordering of accreds
      @default_address = visible_addresses&.first
    end
    @default_address
  end

  # --- rooms

  def rooms(unit_id = nil)
    if unit_id.nil?
      @rooms
    else
      @rooms_by_unit ||= @rooms&.group_by(&:unit_id) || {}
      @rooms_by_unit.key?(unit_id) ? @rooms_by_unit[unit_id] : []
    end
  end

  def room(unit_id = nil)
    rooms(unit_id).first
  end

  def accreditors
    @accreditors ||= Accreditor.for_sciper(@sciper)
  end

  # TODO: check errors on api calls and decide how to recover
  # TODO: once accred for profile is loaded, we can update visibility on address
  def accreditations
    profile = profile!
    @accreditations ||= if profile.present?
                          Accreditation.for_profile(profile)
                        else
                          Accreditation.for_sciper(sciper)
                        end
  end

  def units
    @units ||= accreditations.map(&:unit)
  end

  def positions
    @positions ||= accreditations.sort.map(&:position)
  end

  def position!
    positions.first
  end

  def position
    # The two might not match because the position returned by API is query
    # dependent. On the other hand, it is a waste to load accreds all the time
    @accreditations.present? ? positions.first : @position
  end

  def main_position
    @main_position ||= accreditations.min.position
  end

  def accred_for_unit(unit_id)
    @accreds_by_unit ||= accreditations.group_by(&:unit_id)
    @accreds_by_unit[unit_id]&.first
  end

  def match_position_filter?(filter)
    accreditations.any? do |a|
      a.position.match_legacy_filter?(filter)
    end
  end

  def select_posistions!(filter)
    fa = accreditations.select do |a|
      a.position.match_legacy_filter?(filter)
    end
    return if fa.empty?

    @accreditations = [fa.first]
  end

  def student?
    student.present? || accreditations.any?(&:student?)
  end

  def student
    @student = Student.find_by(sciper: sciper) unless defined?(@student)
    @student
  end

  def doctoral?
    accreditations.any?(&:doctoral?)
  end

  def staff?
    accreditations.any?(&:staff?)
  end

  # TODO: fix once the actual data is available in api
  def class_delegate?
    student.present? && student.delegate?
  end

  # def gender
  #   @data['gender'] || 'unknown'
  # end

  # TODO: We could just check if there are any cours or phd
  def possibly_teacher?
    accreditations.any?(&:possibly_teacher?)
  end

  def professor_emeritus?
    accreditations.any?(&:professor_emeritus?)
  end

  def teacher
    possibly_teacher? ? Teacher.new(self) : nil
  end

  # ----------------------------------------------------------------------------

  # Methods that are not explicitly defined are assumed to be keys of @data
  # Fields that are expected to be always present will except if not found
  def method_missing(key, *args, &blk)
    @data.key?(key.to_s) ? @data[key.to_s] : super
  end

  def respond_to_missing?(key, include_private = false)
    @data.key?(key.to_s) || super
  end

  # Optional fields when not present will get a nil value without failing
  %w[firstnameusual lastnameusual].each do |m|
    define_method m.to_sym do
      @data[m]
    end
  end
end
