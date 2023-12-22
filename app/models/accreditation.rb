# frozen_string_literal: true

class Accreditation
  attr_reader :sciper, :unitid, :unit_name, :position

  include Translatable
  translates :unit_label, :status_label, :class_label

  def initialize(data)
    ud = data.delete('unit')
    sd = data.delete('status')
    cd = data.delete('class')
    @position = data.delete('position')
    @position = Position.new(@position) unless @position.nil?
    @attributes = {
      'sciper': data["persid"],
      'unit_id': ud["id"],
      'unit_name': ud["name"],
      'unit_label_fr': ud["labelfr"],
      'unit_label_en': ud["labelfr"],
      'status_id': sd['id'],
      'status_label_fr': sd['labelfr'],
      'status_label_en': sd['labelfr'],
      'class_label_fr': cd['labelfr'],
      'class_label_en': cd['labelen'],
    }
  end

  def self.for_sciper(sciper)
    accreds = APIAccredsGetter.call(sciper)
    return [] if accreds.empty?

    accreds.map { |data| new(data) }
  end
end
