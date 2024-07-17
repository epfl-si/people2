# frozen_string_literal: true

# Accreditation is the real accred coming from official EPFL accred data
class Accreditation
  attr_accessor :prefs
  attr_reader :sciper, :unit_id, :unit_name, :position, :accred_order, :unit_label_fr, :unit_label_en
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
    @prefs = nil
  end

  # TODO: this is still suboptimal but presently I don't know how to improve it.
  # The problem we are trying to solve is that accreds are changing frequently.
  # Therefore, the two sets (local accred refs and actual accreds) are not
  # guaranteed to be always identical. When an accred is removed we just have
  # to garbage collect the corresponding accre preferency. On the other hand,
  # when an accred is added, we have to decide what is its position.
  # The current implementation assumes the existence of an external ordering
  # from that will be overridden by the local sorting preferences. New accreds
  # will just be appended respecting the external ordering after those with prefs.
  def self.for_profile(profile)
    sciper = profile.sciper
    accreds = for_sciper(sciper)
    prefs = profile.accreds
    unless prefs.empty?
      pbu = prefs.index_by(&:unit_id)
      orders = []
      accreds.each do |a|
        if pbu.key?(a.unit_id)
          a.prefs = pbu[a.unit_id]
          orders << a.prefs.position
        end
      end
      last_order = orders.max
    end
    next_order = (last_order || 0) + 1
    accreds.select { |a| a.prefs.nil? }.sort { |a, b| a.accred_order <=> b.accred_order }.each do |a|
      a.prefs = profile.accreds.new(
        {
          sciper: sciper,
          gender: profile.person.gender,
          unit_id: a.unit_id,
          unit_en: a.unit_label_en,
          unit_fr: a.unit_label_fr,
          role: a.position,
          position: next_order,
        }.merge(Accred::DEFAULTS)
      )
      next_order += 1
    end
    # TODO: cleanup unused accred_prefs if profile.accred_prefs.size > accreds.size
    accreds
  end

  def self.for_profile!(profile)
    accreds = for_profile(profile)
    accreds.each { |a| a.prefs.save if a.prefs.new_record? }
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
    @unit ||= Unit.find(@unit_id)
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
    # 3. (done in prefs) user can decide to hide certains accreds
    unless defined?(@visible)
      @visible =
        botweb? &&
        (prefs.present? ? prefs.visible? : true) &&
        !(Rails.configuration.hide_teacher_accreds && @position.enseignant?)
    end
    @visible
  end

  def hidden_addr?
    prefs.present? && prefs.hidden_addr?
  end

  def order
    prefs.present? ? [prefs.position, @accred_order] : [@accred_order, @accred_order]
  end

  def <=>(other)
    order <=> other.order
  end

  def possibly_teacher?
    position.present? && position.possibly_teacher?
  end
end
