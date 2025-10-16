# frozen_string_literal: true

# TODO: is it worth including ActiveModel::API ?
class Address
  attr_reader :unit_id, :order, :lines, :hierarchy, :full

  def initialize(data)
    @unit_id = data['unitid'].to_i
    @type = data['type']
    @country = data['country']
    @hierarchy = data['part1']
    @lines = (1..5).map { |n| data["part#{n}"] }.compact.reject(&:empty?)
    @full = data['address'] || @lines.join(' $ ')
    @from_default = data['fromdefault'].to_i != 0
  end

  def postal
    @lines[1..]
  end

  def default?
    @from_default
  end

  def eql?(other)
    unit_id == other.unit_id && lines == other.lines
  end
end
