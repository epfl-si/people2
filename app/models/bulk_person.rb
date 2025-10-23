# frozen_string_literal: true

# This is a stripped down version of Person which is meant to carry just the
# information that is needed for wsgetpeople api. Most of the information
# is present in the data coming from APIAccredsGetter instead of APIPersonGetter
class BulkPerson
  MAX_PER_REQUEST = 50

  attr_reader :accreds, :email, :gender, :firstname, :lastname, :profile, :sciper

  def initialize(data, accreds_by_unit, profile: nil, options: nil)
    # super(data)
    @email = data['email']
    @gender = data['gender']
    @firstname = data['firstname']
    @lastname = data['lastname']

    @options = options&.index_by(&:key) || {}

    @profile = profile
    @sciper = data['id']
    accred_prefs_by_unit = @profile&.accreds&.index_by(&:unit_id) || {}

    phones_by_unit = data.delete('phones')&.map { |d| Phone.new(d) }&.group_by(&:unit_id) || {}
    addresses_by_unit = data.delete('addresses')&.map { |d| Address.new(d) }&.group_by(&:unit_id) || {}
    rooms_by_unit = data.delete('rooms')&.map { |d| Room.new(d) }&.group_by(&:unit_id) || {}

    unit_ids = accreds_by_unit.keys
    cdata = []
    unit_ids.each_with_index do |uid, i|
      ap = accred_prefs_by_unit[uid]
      next unless ap.nil? || ap.public?

      addr = addresses_by_unit[uid]
      phones = phones_by_unit[uid]
      rooms = rooms_by_unit[uid]
      r = {
        unit_id: uid,
        rank: ap&.position || 100 + i
      }
      r[:address] = addr if addr.present? && ap.present? && ap.address_visible?
      r[:phones] = phones if phones.present?
      r[:rooms] = rooms if rooms.present?

      a = accreds_by_unit[uid]

      r[:position] = a.position
      r[:position_en] = a.position.t_label(@gender, 'en')
      r[:position_fr] = a.position.t_label(@gender, 'fr')

      r[:status_label_en] = a.t_status_label 'en'
      r[:status_label_fr] = a.t_status_label 'fr'

      r[:unit] = a.bunit

      cdata << BulkAccred.new(r)
    end
    @accreds = cdata.sort { |a, b| a.rank <=> b.rank }
  end

  # pdata is an hash with scipers as keys and data from APIPersonGetter as values
  # adata is an hash with
  def self.from_data(pdata, adata)
    scipers = pdata.keys
    opts = SpecialOption.where(sciper: scipers).group_by(&:sciper)

    # we could already select only those that are visible but I prefer to have
    # all the data anyway in case we need it for other things.
    # where(accreds: {visibility: AudienceLimitable::VISIBLE})
    profiles = Profile.where(sciper: scipers).includes(:pictures, :accreds).index_by(&:sciper)
    pdata.values.map do |d|
      sciper = d["id"]
      new(d, adata[sciper], profile: profiles[sciper], options: opts[sciper])
    end
  end

  def self.for_scipers(scipers, adata: nil, filterbotweb: true)
    scipers = [scipers] unless scipers.is_a?(Array)
    if scipers.count > MAX_PER_REQUEST
      scipers.each_slice(MAX_PER_REQUEST).map do |scipers_batch|
        for_scipers(scipers_batch, adata: adata)
      end.flatten
    else
      adata ||= Accreditation.by_sciper(persid: scipers)
      scipers = Authorisation.filter_scipers_with_property(scipers, property: 'botweb') if filterbotweb
      pdata = APIPersonGetter.call(persid: scipers, single: false).index_by { |v| v["id"] }
      from_data(pdata, adata)
    end
  end

  # By default (all: false) for branch non-leaf, we return a simplified version
  # including professors only (classid: 5, 6)
  # When we create BulkPerson from an unit we are
  # only interested in the accreds for the given unit
  def self.for_unit(u, all: false)
    if !all && u.level < 4
      adata = Accreditation.by_sciper(classid: [5, 6], unitid: u.id)
      scipers = adata.map { |a| a["persid"] }.uniq
      okscipers = Authorisation.filter_scipers_with_property(scipers, property: 'botweb', units: [u.id])
      return for_scipers(okscipers, adata: adata, filterbotweb: false)
    end
    adata = Accreditation.by_sciper(unitid: u.id)
    pdata = APIPersonGetter.call(unitid: u.id).index_by { |v| v["id"] }
    okscipers = Authorisation.filter_scipers_with_property(pdata.keys, property: 'botweb', units: [u.id])
    pdata = pdata.slice(*okscipers)
    from_data(pdata, adata)
  end

  def self.for_units(units, all: false)
    return for_unit(units) unless units.is_a?(Array)

    fu = units.first
    if units.count == 1
      for_unit(fu, all: all)
    elsif !all && fu.level < 4
      adata = Accreditation.by_sciper(classid: [5, 6], unitid: units.map(&:id))
      scipers = Authorisation.filter_scipers_with_property(adata.keys, property: 'botweb', units: uids)
      for_scipers(scipers, adata: adata, filterbotweb: false)
    # if we have several units, it is better to get all the scipers at once and avoid duplicates
    else
      uids = units.map(&:id)
      units.map do |u|
        adata = Accreditation.by_sciper(unitid: u.id)
        pdata = APIPersonGetter.call(unitid: u.id).index_by { |v| v["id"] }
        okscipers = Authorisation.filter_scipers_with_property(pdata.keys, property: 'botweb', units: uids)
        pdata = pdata.slice(*okscipers)
        from_data(pdata, adata)
      end.flatten
    end
  end

  def self.for_group(g)
    for_groups([g])
  end

  def self.for_groups(group_names)
    gnames = group_names.is_a?(Array) ? group_names : [group_names]
    scipers = gnames.map do |gn|
      # unique id for groups is in the form Snnnnn
      id = if gn =~ /S[0-9]{5}/
             gn
           else
             Group.find_by(name: gn)&.id
           end
      if id.present?
        members = APIGroupMembersGetter.call(id: id, recursive: 1)
        members&.map { |m| m["id"] } || []
      else
        []
      end
    end.flatten.uniq
    for_scipers(scipers)
  end

  def match_position_filter?(filter)
    @accreds.any? do |a|
      a.position.match_legacy_filter?(filter)
    end
  end

  def public_email
    o = @options[:mail]
    o.present? ? o.email : email
  end

  def select_posistions!(filter)
    fa = @accreds.select do |a|
      a.position.match_legacy_filter?(filter)
    end
    return if fa.empty?

    @accreds = [fa.first]
  end
end
