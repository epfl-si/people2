# frozen_string_literal: true

class Unit
  attr_reader :id, :hierarchy, :level, :type, :address, :url

  include Translatable
  translates :name, :label

  def initialize(data)
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
    # @type = data['unittype']['label']
    @url = data['url']
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
end
