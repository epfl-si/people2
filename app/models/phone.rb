# frozen_string_literal: true

class Phone
  include Comparable
  attr_reader :unit_id, :order, :number

  def initialize(data)
    @unit_id = data['unitid'].to_i
    @order = data['order'].to_i
    @hidden = data['hidden'].to_i != 0
    @number = data['number']
    @from_default = data['fromdefault'].to_i != 0
  end

  def hidden?
    @hidden
  end

  def visible?
    !@hidden
  end

  def default?
    @from_default
  end

  def <=>(other)
    order <=> other.order
  end
end
