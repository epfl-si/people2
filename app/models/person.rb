# frozen_string_literal: true

# This class represents a person as described by api.epfl.ch
class Person
  attr_reader :data, :name

  private_class_method :new

  # has one profile

  def initialize(person)
    @data = person
    @position = @data.delete('position')
    @position = Position.new(@position) unless @position.nil?

    @account = @data.delete('account') || {}
    @automap = @data.delete('automap') || {}
    @camipro = @data.delete('camipro') || {}

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

  def self.find(sciper_or_email)
    data = if sciper_or_email.is_a?(Integer) || sciper_or_email =~ /^\d{6}$/
             APIPersonGetter.call!(persid: sciper_or_email, single: true)
           else
             APIPersonGetter.call!(email: sciper_or_email, single: true)
           end
    new(data)
  end

  def self.for_scipers(scipers)
    return [] if scipers.empty?

    # sort.uniq is to minimize cache miss
    us = scipers.sort.uniq
    if us.count > 1
      APIPersonGetter.call!(persid: us).map { |p| new(p) }
    else
      [new(APIPersonGetter.call!(persid: us))]
    end
  end

  def self.for_units(units)
    uorids = units.is_a?(Array) ? units : [units]
    ids = if uorids.first.respond_to?(:id)
            uorids.map(&:id).sort.uniq
          else
            uorids.sort.uniq
          end
    APIPersonGetter.call(unitid: ids).map { |p| new(p) }.reject do |p|
      ids.map { |id| p.accred_for_unit(id) }.compact.select(&:botweb?).empty?
    end
  end

  def self.for_groups(group_names)
    gnames = group_names.is_a?(Array) ? group_names : [group_names]
    scipers = gnames.map do |gn|
      # unique id for groups is in the form Snnnnn
      id = if gn =~ /S[0-9]{5}/
             gn
           else
             Group.find_by(name: name)&.id
           end
      if id.present?
        members = APIGroupMembersGetter.call(id: id)
        members.map { |m| m["id"] }
      else
        []
      end
    end.flatten.uniq
    for_scipers(scipers)
  end

  def profile!
    unless defined?(@profile)
      @profile = Profile.for_sciper(sciper)
      @profile = Profile.new_with_defaults(sciper) if @profile.nil? && can_have_profile?
    end
    @profile
  end

  def can_have_profile?
    unless defined?(@can_have_profile)
      @can_have_profile = begin
        a = Authorisation.property_for_sciper(sciper, "botweb")
        a.any? { |d| d.active? && d.ok? }
      end
    end
    @can_have_profile
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
      @account.merge(@automap).merge(@camipro).merge({ sciper: sciper })
    )
  end

  def email
    @data["email"] || ""
  end

  # TODO: check if this is always the case as there might be issues with people
  #       changing name, with modified usual names etc.
  def email_user
    email.gsub(/@.*$/, '')
  end

  def option(key)
    # TODO: this is an N+1 trigger. Since the table is small, we could load it in memory at boot time;
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

  # Updated visible_phones method
  def visible_phones(unit_id = nil)
    phones(unit_id)&.select(&:visible?) || []
  end

  def default_phone
    @default_phone = visible_phones.min unless defined?(@default_phone)
    @default_phone
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

  # TODO: fix once the actual data is available in api
  def class_delegate?
    rand(1..10) == 1
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
    accreditations.any?(&:student?)
  end

  # def gender
  #   @data['gender'] || 'unknown'
  # end

  # TODO: see if it is possible to guess if person could be a teacher in order
  # to avoid useless requests to ISA.
  def possibly_teacher?
    accreditations.any?(&:possibly_teacher?)
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

  def courses
    Course.joins(:teacherships)
          .where(teacherships: { sciper: sciper })
  end
end
