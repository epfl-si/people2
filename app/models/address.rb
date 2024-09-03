# frozen_string_literal: true

# TODO: is it worth including ActiveModel::API ?
class Address
  attr_reader :unit_id, :order, :lines, :hierarchy

  def initialize(data)
    @unit_id = data['unitid'].to_i
    @type = data['type']
    @country = data['country']
    @hierarchy = data['part1']
    @lines = (2..4).map { |n| data["part#{n}"] }.compact.reject(&:empty?)
    @from_default = data['fromdefault'].to_i != 0
  end

  def default?
    @from_default
  end

  def full
    @lines.join(' $ ')
  end
end
