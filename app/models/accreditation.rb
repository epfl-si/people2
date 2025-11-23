# frozen_string_literal: true

# Accreditation is the real accred coming from official EPFL accred data
class Accreditation
  attr_accessor :prefs, :status_id
  attr_reader :sciper, :bunit, :unit_id, :position, :accred_order
  attr_writer :unit, :botweb, :gestprofil

  include ActiveModel::Model

  include Translatable
  translates :unit_label, :status_label, :class_label

  def initialize(data)
    @bunit = BulkUnit.new(data.delete('unit'))
    @unit_id = @bunit.id

    sd = data.delete('status')
    data.delete('class')
    @sciper = data['persid']

    @status_id = sd['id'].to_i
    # api.epfl.ch does not provide status labels in it and de
    @status_label_fr = sd['labelfr']
    @status_label_en = sd['labelen']
    @status_label_it = sd['labelen']
    @status_label_de = sd['labelen']
    @accred_order = data['order'].to_i

    # TODO: check if using status where position is not provided makes sense
    # TODO: inclusive position (at least for students)
    posdata = data.delete('position')
    if posdata.nil?
      posdata = if student?
                  {
                    "labelfr" => "Etudiant",
                    "labelen" => "Student",
                    "labelxx" => "Etudiante",
                    "labelinclusive" => "Etudiante/Etudiant",
                  }
                else
                  data.delete('position') || {
                    'labelen' => @status_label_en,
                    'labelfr' => @status_label_fr,
                  }
                end
    end
    @position = Position.new(posdata)
    @prefs = nil
  end

  # In api.epfl.ch, the id of an accred is built as follows: id="#{sciper}:#{unit_id}"
  def self.find(id)
    data = APIAccredsGetter.call(id: id)
    raise RecordNotFound if data.blank?

    new(data)
  end

  def id
    "#{@sciper}:#{@unit_id}"
  end

  def accreditors
    @accreditors ||= Accreditor.for_sciper(@sciper).uniq(&:sciper)
  end

  # TODO: this is still suboptimal but presently I don't know how to improve it.
  # The problem we are trying to solve is that accreds are changing frequently.
  # Therefore, the two sets (local accred refs and actual accreds) are not
  # guaranteed to be always identical. When an accred is removed we just have
  # to garbage collect the corresponding accred preference. On the other hand,
  # when an accred is added, we have to decide what is its position.
  # The current implementation assumes the existence of an external ordering
  # from that will be overridden by the local sorting preferences. New accreds
  # will just be appended respecting the external ordering after those with prefs.
  def self.for_profile(profile, force: false)
    sciper = profile.sciper
    accreds = for_sciper(sciper, force: force)
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
      # remove no longer relevant accred prefs
      (pbu.keys - accreds.map(&:unit_id)).each { |uid| pbu[uid].destroy }
    end
    next_order = (last_order || 0) + 1
    accreds.select { |a| a.prefs.nil? }.sort { |a, b| a.accred_order <=> b.accred_order }.each do |a|
      a.prefs = profile.accreds.new(
        Accred::DEFAULTS.merge({
                                 sciper: sciper,
                                 unit_id: a.unit_id,
                                 unit_en: a.unit_label_en,
                                 unit_fr: a.unit_label_fr,
                                 role: a.position,
                                 position: next_order,
                               })
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

  # This is meant for single profile as it is firing a lot of requests
  def self.for_sciper(sciper, force: false, all: false)
    accreds_data = APIAccredsGetter.call(persid: sciper, force: force)
    return [] if accreds_data.empty?

    accreds = accreds_data.map { |data| new(data) }

    # prefetch botweb and unit properties for all accreds at once for optimization
    botwebs = Authorisation.property_for_sciper(sciper, 'botweb').select(&:ok?).index_by(&:unit_id)
    gestprofils = Authorisation.property_for_sciper(sciper, 'gestprofil').select(&:ok?).index_by(&:unit_id)
    units = APIUnitGetter.call(ids: accreds.map(&:unit_id)).map { |d| Unit.new(d) }.index_by(&:id)
    accreds.each do |a|
      a.unit = units[a.unit_id]
      a.botweb = botwebs.key?(a.unit_id.to_s) || false
      a.gestprofil = gestprofils.key?(a.unit_id.to_s) || false
    end
    # TODO: remove me after final import for production
    # During development we do not want to import everything upfront.
    # Therefore, we import on request when needed.
    if Rails.env.development? && accreds.any?(&:gestprofil?) && Profile.for_sciper(sciper).blank? # && accreds.count > 1
      LegacyProfileImportJob.perform_later(sciper)
    end
    # By default we are actually interested exclusively on visible accreditations
    (all ? accreds : accreds.select(&:botweb?)).sort { |a, b| a.order <=> b.order }
  end

  # *conditions are valid arguments for APIAccredsGetter.call
  # Returns an hash with scipers as keys and an hash as value where the
  # value hash has unit_ids as keys and corresponding Accreditation as value
  # sciper1 => {
  #   unit_id1 => Accred1,
  #   unit_id2 => Accred2,
  # },
  # sciper2 => {
  #   unit_id3 => Accred3,
  #   unit_id4 => Accred4,
  # },...
  # Examples:
  #  * Accreditation.by_sciper(unitid: 13030)
  #  * Accreditation.by_sciper(classid: [5, 6], unitid: 13217)
  #  * Accreditation.by_sciper(persid: [121769, ...])
  def self.by_sciper(*conditions)
    acdata_by_sciper = APIAccredsGetter.call(*conditions).group_by do |v|
      v["persid"].to_s
    end
    acdata_by_sciper.transform_values do |alist|
      alist.sort { |a, b| a["order"] <=> b["order"] }.map do |data|
        a = new(data)
        [a.unit_id, a]
      end.to_h
    end
  end

  def self.for_all_full_professors
    accreds_data = APIAccredsGetter.call(classid: 5)
    accreds_data.map { |data| new(data) }
  end

  def self.for_all_professors
    accreds_data = APIAccredsGetter.call(classid: [5, 6])
    accreds_data.map { |data| new(data) }
  end

  def unit
    @unit ||= Unit.find(@unit_id)
  end

  # delegate(:unit_name, :unit_label_en, :unit_label_fr, :unit_label_it, :unit_label_de, to: :bunit)
  def unit_name
    @bunit.name
  end

  def unit_label_en
    @bunit.label_en
  end

  def unit_label_fr
    @bunit.label_fr
  end

  def unit_label_it
    @bunit.label_it
  end

  def unit_label_de
    @bunit.label_de
  end

  def botweb?
    unless defined?(@botweb)
      aa = Authorisation.property_for_sciper(sciper, 'botweb')
      @botweb = aa.find { |a| a.unit_id == @unit_id && a.ok? }.present?
    end
    @botweb
  end

  def gestprofil?
    unless defined?(@gestprofil)
      aa = Authorisation.property_for_sciper(sciper, 'gestprofil')
      @gestprofil = aa.find { |a| a.unit_id == @unit_id && a.ok? }.present?
    end
    @gestprofil
  end

  def profile
    Profile.for_sciper(@sciper)
  end

  # If the person is a bachelor or master student (does not include PhDs)
  def student?
    # $is_student         = 1 if $accred->{statusid} =~ /^(4|5|6)$/;
    3 < @status_id && @status_id < 7
  end

  # Is part of a doctoral schoold => is a graduate (PhD) student
  def doctoral?
    unit.hierarchy.split(" ")[2] == "EDOC"
  end

  # This include anyone with a salary => also PhDs
  def staff?
    @status_id == 1
  end

  def visible?
    visible_by?(AudienceLimitable::WORLD)
  end

  def visible_by?(audience = AudienceLimitable::WORLD)
    # There are actually 3 level of visibility check for accreditations.
    # 1. must have the 'botweb' property (self.for_sciper)
    # 2. (done here) purely teaching position can be hidden
    # 3. (done in prefs) user can decide to hide certains accreds
    # @visibility hash memoizes
    @visibility ||= {}
    return @visibility[audience] if @visibility.key?(audience)

    @visibility[audience] = botweb? &&
                            (prefs.present? ? prefs.visible_by?(audience) : true) &&
                            !(Rails.configuration.hide_teacher_accreds &&
                              @position.enseignant_but_not_emeritus?
                             )
  end

  # def hidden?
  #   !visible?
  # end

  def hidden_addr?
    prefs.present? && prefs.address_hidden?
  end

  def order
    prefs.present? ? [prefs.position, @accred_order] : [@accred_order, @accred_order]
  end

  def <=>(other)
    order <=> other.order
  end

  # TODO: this is an orrible hack. We definitly need to find a more solid solution
  def possibly_teacher?
    unit.id == 16 || position.present? && position.possibly_teacher?
  end

  def professor_emeritus?
    position.present? && position.professor_emeritus?
  end
end
