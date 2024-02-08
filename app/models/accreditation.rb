# frozen_string_literal: true

class Accreditation
  attr_reader :sciper, :unit_id, :unit_name, :position
  attr_writer :unit, :botweb

  include Translatable
  translates :unit_label, :status_label, :class_label

  def initialize(data)
    ud = data.delete('unit')
    sd = data.delete('status')
    data.delete('class')
    @sciper = data['persid']
    @unit_id = ud["id"].to_i
    @unit_name = ud["name"]
    @unit_label_fr = ud["labelfr"]
    @unit_label_en = ud["labelfr"]
    @status_id = sd['id'].to_i
    @status_label_fr = sd['labelfr']
    @status_label_en = sd['labelfr']
    @accred_order = data['order'].to_i

    # TODO: check if using status where position is not provided makes sense
    # TODO: inclusive position (at least for students)
    posdata = data.delete('position') || {
      'labelen' => @status_label_en,
      'labelfr' => @status_label_fr,

    }
    @position = Position.new(posdata)
  end

  def self.for_profile(profile)
    sciper = profile.sciper
    accreds = for_sciper(sciper)
    ap = profile.accred_prefs.index_by(&:unit_id)
    accreds.each do |a|
      a.prefs = if ap.key?(a.unit_id)
                  ap[a.unit_id]
                else
                  profile.accred_prefs.new(
                    {
                      unit_id: a.unit_id,
                      sciper: sciper,
                    }.merge(AccredPref::DEFAULTS)
                  )
                end
    end
    accreds
  end

  def self.for_sciper(sciper)
    service = APIAccredsGetter.for_sciper(sciper)
    accreds_data = service.fetch
    return [] if accreds_data.empty?

    accreds = accreds_data.map { |data| new(data) }

    # prefetch botweb and unit properties for all accreds at once for optimization
    botwebs = Authorisation.botweb_for_sciper(sciper).select(&:ok?).index_by(&:unit_id)
    units = APIUnitGetter.fetch_units(accreds.map(&:unit_id)).map { |d| Unit.new(d) }.index_by(&:id)

    accreds.each do |a|
      a.unit = units[a.unit_id]
      a.botweb = botwebs.key?(a.unit_id.to_s) ? true : false
    end
    accreds
  end

  def unit
    @unit ||= begin
      unit_data = APIUnitGetter.fetch_units(@unit_id)
      Unit.new(unit_data)
    end
  end

  def prefs=(p)
    raise 'Unexpected class' unless p.is_a?(AccredPref)

    @prefs = p
  end

  def prefs
    # this is not a valid record
    @prefs ||= AccredPrefs.new(AccredPrefs::DEFAULTS)
  end

  def botweb?
    unless defined?(@botweb)
      aa = Authorisation.botweb_for_sciper(sciper)
      @botweb = aa.find { |a| a.unit_id == @unit_id && a.ok? }.present?
    end
    @botweb
  end

  def visible?
    # There are actually 3 level of visibility check fir accreditations.
    # 1. must have the 'botweb' property (self.for_sciper)
    # 2. (done here) purely teaching position can be hidden
    # 3. (done in prefs) user can decide ti hide certains accreds
    unless defined?(@visible)
      @visible =
        botweb? &&
        prefs.visible? &&
        !(Rails.configuration.hide_teacher_accreds && @position.enseignant?)
    end
    @visible
  end

  def hidden_address?
    prefs.hidden_addr
  end

  def order
    [prefs.order, @accred_order]
  end

  def <=>(other)
    order <=> other.order
  end

  def possibly_teacher?
    position.nil? ? false : position.possibly_teacher?
  end
end
