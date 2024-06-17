# frozen_string_literal: true

# This class represents a person as described by api.epfl.ch
class Person
  attr_reader :data, :position, :name

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
    @phones = (@data.delete('phones') || []).map { |d| Phone.new(d) }.group_by(&:unit_id)
    @addresses = (@data.delete('addresses') || []).map { |d| Address.new(d) }.group_by(&:unit_id)

    @name = Name.new({
                       id: sciper,
                       usual_first: @data.delete('firstnameusual'),
                       usual_last: @data.delete('lastnameusual'),
                       official_first: @data.delete('firstname'),
                       official_last: @data.delete('lastname'),
                     })
  end

  def self.find(sciper_or_email)
    g = if sciper_or_email.is_a?(Integer) || sciper_or_email =~ /^\d{6}$/
          APIPersonGetter.for_sciper(sciper_or_email)
        else
          APIPersonGetter.for_email(sciper_or_email)
        end
    p = g.fetch!
    new(p)
  end

  def profile
    @profile = Profile.for_sciper(sciper) unless defined?(@profile)
    @profile = Profile.create_with_defaults(sciper) if @profile.nil? && can_edit_profile?
    @profile
  end

  def can_edit_profile?
    unless defined?(@can_edit_profile)
      @can_edit_profile = begin
        a = APIAuthGetter.new(sciper).fetch
        a.any? { |d| d['status'] == 'active' }
      end
    end
    @can_edit_profile
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

  # TODO: check if this is always the case as there might be issues with people
  #       changing name, with modified usual names etc.
  def email_user
    email.gsub(/@.*$/, '')
  end

  def sciper
    id
  end

  def visible_phones(unit)
    @phones.present? ? @phones[unit].select(&:visible?) : []
  end

  def phones(unit)
    @phones[unit]
  end

  def addresses(unit)
    @addresses.key?(unit) ? @addresses[unit] : []
  end

  def address(unit)
    addresses(unit).first
  end

  def default_phone
    unless defined?(@default_phone)
      @default_phone = @phones.present? ? @phones.values.flatten.select(&:visible?).flatten.min : nil
    end
    @default_phone
  end

  # TODO: fix once the actual data is available in api
  def class_delegate?
    rand(1..10) == 1
  end

  # TODO: check errors on api calls and decide how to recover
  def accreditations
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
    @positions ||= accreditations.map(&:position)
  end

  def main_position
    @main_position ||= accreditations.min.position
  end

  def student?
    accreditations.any?(&:student?)
  end

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
end
