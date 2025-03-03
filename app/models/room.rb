# frozen_string_literal: true

class Room
  attr_reader :id, :unit_id, :name, :order

  PLAN_URL = URI.parse("https://plan.epfl.ch/")

  def initialize(data)
    @id      = data['id'].to_i
    @unit_id = data['unitid'].to_i
    @name    = data['name']
    @order   = data['order'].to_i
    @hidden  = data['hidden'].to_i == 1
    @from_default = data['fromdefault'].to_i != 0
  end

  def visible?
    !@hidden
  end

  def hidden?
    @hidden
  end

  def default?
    @from_default
  end

  def eql?(other)
    name == other.name
  end

  def url
    u = PLAN_URL
    u.query = URI.encode_www_form(room: @name)
    u
  end
end
