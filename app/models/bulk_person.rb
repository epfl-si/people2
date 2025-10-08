# frozen_string_literal: true

# This is a stripped down version of Person which is meant to carry just the
# information that is needed for wsgetpeople api. Most of the information
# is present in the data coming from APIAccredsGetter instead of APIPersonGetter
class BulkPerson < Person
  MAX_PER_REQUEST = 50

  attr_reader :contacts

  def initialize(data, profile: nil)
    super(data)
    @profile = profile

    addresses_by_unit ||= @addresses&.group_by(&:unit_id) || {}
    phones_by_unit ||= @phones&.group_by(&:unit_id) || {}
    rooms_by_unit ||=  @rooms&.group_by(&:unit_id) || {}
    accreds_by_unit = @profile&.accreds&.index_by(&:unit_id) || {}
    unit_ids = (addresses_by_unit.keys + phones_by_unit.keys + rooms_by_unit.keys).uniq
    @contacts = []
    unit_ids.each_with_index do |uid, i|
      a = accreds_by_unit[uid]
      next unless a.nil? || a.public?

      addr = addresses_by_unit[uid]
      phones = phones_by_unit[uid]
      rooms = rooms_by_unit[uid]
      r = {
        unit_id: uid,
        rank: a&.position || 100 + i
      }
      r[:address] = addr if addr.present? && a.present? && a.address_visible?
      r[:phones] = phones if phones.present?
      r[:rooms] = rooms if rooms.present?

      # TODO: in order to get the real position for a given unit we currently have
      #       no other way than calling /accreds on api foreach sciper or anyway
      #       implement a set of bulk requests. In first approximation, I am just
      #       going to use the main position for all units and decide what to do
      #       depending on the number of complains. In the mean time, IAM might
      #       have accepted my proposal (see https://go.epfl.ch/INC0747429) of
      #       including all the positions similarly to what is done for phones etc.
      r[:position] = @position

      @contacts << OpenStruct.new(r) # .with_indifferent_access
    end
    @contacts.sort! { |a, b| a.rank <=> b.rank }
  end

  # pdata is an hash with scipers as keys and data from APIAccredsGetter as values
  def self.from_data(pdata)
    scipers = pdata.keys
    # we could already select only those that are visible by I prefer to have
    # all the data anyway in case we need it for other things.
    # where(accreds: {visibility: AudienceLimitable::VISIBLE})
    profiles = Profile.where(sciper: scipers).includes(:pictures, :accreds).index_by(&:sciper)
    pdata.values.map do |d|
      new(d, profile: profiles[d["id"]])
    end
  end

  def self.for_scipers(scipers)
    scipers = [scipers] unless scipers.is_a?(Array)
    if scipers.count > MAX_PER_REQUEST
      pdata = scipers.each_slice(MAX_PER_REQUEST).map do |scipers_batch|
        for_scipers(scipers_batch)
      end.flatten
    else
      okscipers = Authorisation.filter_scipers_with_property(scipers, 'botweb')
      pdata = APIPersonGetter.call(persid: okscipers, single: false).index_by { |v| v["id"] }
    end
    from_data(pdata)
  end

  # By default (all: false) for branch non-leaf, we return a simplified version
  # including professors only (classid: 5,6)
  def self.for_unit(u, all: false)
    if !all && u.level < 4
      adata = APIAccredsGetter.call(classid: [5, 6], unitid: u.id)
      scipers = adata.map { |a| a["persid"] }.uniq
      return for_scipers(scipers)
    end
    pdata = APIPersonGetter.call(unitid: u.id).index_by { |v| v["id"] }
    okscipers = Authorisation.filter_scipers_with_property(pdata.keys, 'botweb')
    pdata = pdata.slice(*okscipers)
    from_data(pdata)
  end

  def self.for_units(units, all: false)
    return unless units.is_a?(Array)

    fu = units.first
    if units.count == 1
      for_unit(fu, all: all)
    elsif !all && fu.level < 4
      adata = APIAccredsGetter.call(classid: [5, 6], unitid: units.map(&:id))
      scipers = adata.map { |a| a["persid"] }.uniq
      for_scipers(scipers)
    # if we have several units, it is better to get all the scipers at once and avoid duplicates
    else
      units.map { |u| for_unit(u) }.flatten
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
        members = APIGroupMembersGetter.call(id: id)
        members&.map { |m| m["id"] } || []
      else
        []
      end
    end.flatten.uniq
    for_scipers(scipers)
  end
end
