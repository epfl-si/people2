# frozen_string_literal: true

class Unit
  attr_reader :id, :hierarchy, :level, :type, :address, :url

  include Translatable
  translates :name, :label

  def self.find(id)
    unit_data = APIUnitGetter.call(id: id)
    new(unit_data)
  end

  def self.find_by_name(name, force: false)
    unit_data = APIUnitGetter.call(name: name, single: true, force: force)
    new(unit_data)
  end

  def initialize(data)
    Rails.logger.debug("Unit::init: data=#{data.inspect}")

    @id = data['id']
    @name_fr = data['name']
    @name_en = data['nameen']
    @name_de = data['namede']
    @name_it = data['nameid']
    @label_fr = data['labelfr']
    @label_en = data['labelen']
    @label_de = data['labelde']
    @label_it = data['labelid']
    @hierarchy = data['path']
    @level = data['level']
    @parent_id = data['parentid']
    @kind = data['type']
    @resp_id = data['responsibleid']
    # @type = data['unittype']['label']
    @url = data['url']
    @direct_children_ids = data['directchildren'].split(",").map(&:to_i)
    @all_children_ids = data['allchildren'].split(",").map(&:to_i)
    @address = Address.new(
      'unitid' => @id,
      'country' => data['country'],
      'hierarchy' => @hierarchy,
      'part1' => data['address1'],
      'part2' => data['address2'],
      'part3' => data['address3'],
      'part4' => data['address4'],
      'city' => data['city']
    )
  end

  def direct_children
    @direct_children ||= @direct_children_ids.map { |id| Unit.find(id) }
  end

  def all_children
    @all_children ||= @all_children_ids.map { |id| Unit.find(id) }
  end
end
