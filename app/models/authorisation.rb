# frozen_string_literal: true

class Authorisation
  attr_reader :name, :sciper, :unit_id, :type

  include Translatable
  translates :label

  def initialize(data)
    @type = data['type']
    @sciper = data['persid']
    # resource is more generic but we only use it as unit (I think...)
    @unit_id = data['resourceid']
    @value = data['value']
    @label_en = data['labelen']
    @label_fr = data['label_fr']
    @name = data['name']
  end

  def ok?
    @value[0] == 'y'
  end

  def self.botweb_for_sciper(sciper)
    service = APIAuthGetter.new(sciper: sciper, authid: 'botweb')
    auth_data = service.fetch
    return [] if auth_data.empty?

    auth_data.map { |data| new(data) }
  end

  def self.right_for_sciper(sciper, right = 'AAR.report.control')
    service = APIAuthGetter.new(sciper: sciper, type: 'right', authid: right)
    auth_data = service.fetch
    return [] if auth_data.empty?

    auth_data.map { |data| new(data) }
  end
end
