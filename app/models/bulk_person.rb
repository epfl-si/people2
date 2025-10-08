# frozen_string_literal: true

# This is a stripped down version of Person which is meant to carry just the
# information that is needed for wsgetpeople api. Most of the information
# is present in the data coming from APIAccredsGetter instead of APIPersonGetter
class BulkPerson < Person
  MAX_PER_REQUEST = 160

  def initialize(data, profile: nil)
    super(data)
    @profile = profile
  end

  # pdata is an hash with scipers as keys and data from APIAccredsGetter as values
  def self.from_data(pdata)
    scipers = pdata.keys
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
    return unless units.is_as?(Array)

    fu = units.first
    if units.count == 1
      for_unit(fu, all)
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
