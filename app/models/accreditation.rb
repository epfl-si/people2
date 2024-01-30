# frozen_string_literal: true

class Accreditation
  attr_reader :sciper, :unit_id, :unit_name, :position, :order
  attr_writer :unit

  include Translatable
  translates :unit_label, :status_label, :class_label

  def initialize(data, opts = nil)
    ud = data.delete('unit')
    sd = data.delete('status')
    data.delete('class')
    @position = data.delete('position')
    @position = Position.new(@position) unless @position.nil?
    @sciper = data['persid']
    @unit_id = ud["id"]
    @unit_name = ud["name"]
    @unit_label_fr = ud["labelfr"]
    @unit_label_en = ud["labelfr"]
    @status_id = sd['id']
    @status_label_fr = sd['labelfr']
    @status_label_en = sd['labelfr']
    @order = data['order']

    # @class_label_fr = cd['labelfr']
    # @class_label_en = cd['labelen']

    # default values. Should be reset in set_options.
    @people_order = 1
    @visible = true
    @hidden_address = false

    set_options(opts) unless opts.nil?
  end

  def self.for_sciper(sciper)
    service = APIAccredsGetter.for_sciper(sciper)
    accreds_data = service.fetch
    return [] if accreds_data.empty?

    accreds = accreds_data.map { |data| new(data) }

    # TODO: ask IAM if we can avoid N+1 queries
    units = APIUnitGetter.fetch_units(accreds.map(&:unit_id)).map { |d| Unit.new(d) }.index_by(&:id)
    accreds.each do |a|
      a.unit = units[a.unit_id]
    end
    accreds
  end

  def unit
    @unit ||= begin
      unit_data = APIUnitGetter.fetch_units(@unit_id)
      Unit.new(unit_data)
    end
  end

  def hidden_address?
    set_options unless defined?(@hidden_address)
    @hidden_address
  end

  def hidden_office?
    set_options unless defined?(@hidden_office)
    @hidden_office
  end

  def people_order
    set_options unless defined?(@people_order)
    @people_order
  end

  def <=>(other)
    [@people_order, @order] <=> [other.people_order, other.order]
  end

  def visible?
    unless defined?(@visible)
      if Rails.configuration.hide_teacher_accreds && @position.enseignant?
        @visible = false
      else
        set_options
      end
    end
    @visible
  end

  def set_options(opts = AccredPref.for_sciper(@sciper).find { |o| o.unit_id == @unit_id })
    # fetching all the prefs for this sciper I hope to avoid multiple
    # sql requests thanks to AR caching

    if opts.nil?
      # default values if nothing was found about this unit
      @people_order = 1
      @visible = true
      @hidden_address = false
    else
      @people_order = opts.order
      @visible = opts.visible?
      @hidden_address = opts.hidden_addr
    end
  end
end
