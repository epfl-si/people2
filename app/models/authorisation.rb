# frozen_string_literal: true

class Authorisation
  attr_reader :name, :sciper, :resource_id, :type

  include Translatable
  translates :label

  def initialize(data)
    @type = data['type']
    @sciper = data['persid']
    # resource is more generic but we only use it as unit (I think...)
    @resource_id = data['resourceid']
    @value = data['value']
    @status = data['status']
    @label_en = data['labelen']
    @label_fr = data['label_fr']
    @name = data['name']
  end

  def ok?
    @value[0] == 'y'
  end

  def active?
    @status
  end

  def unit_id
    @resource_id
  end

  # TODO: do we really need these aliases ?
  def self.botweb_for_sciper(sciper)
    property_for_sciper(sciper, 'botweb')
  end

  def self.aar_for_sciper(sciper)
    right_for_sciper(sciper, 'AAR.report.control')
  end

  # TODO: check that the given property is in the list of available properties
  def self.property_for_sciper(sciper, property = 'botweb')
    auth_data = APIAuthGetter.call(persid: sciper, authid: property, type: 'property')
    return [] if auth_data.empty?

    auth_data.map { |data| new(data) }
  end

  def self.right_for_sciper(sciper, right = 'AAR.report.control')
    auth_data = APIAuthGetter.call(persid: sciper, type: 'right', authid: right)
    return [] if auth_data.empty?

    auth_data.map { |data| new(data) }
  end
end
