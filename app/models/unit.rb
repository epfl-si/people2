# frozen_string_literal: true

# TODO: We may consider transforming this into a local Model as we can refresh it
#   nigthly very easily as we do for scipers. The call to api /units gives the full list.
#   ./bin/rails g migration create_units --database=work \
#     name_en:string name_fr:string name_it:string name_de:string \
#     label_en:string label_fr:string label_it:string label_de:string \
#     level:integer resp_id:string kind:string address:string \
#     ancestors:string direct_children:string  all_children:string
class Unit
  attr_reader :id, :parent_id, :hierarchy, :label, :level, :name, :type, :address, :url

  include Translatable
  translates :name, :label

  def self.find(id)
    raise "Invalid id #{id}" if id.to_i.zero?

    unit_data = APIUnitGetter.call(id: id)
    # TODO: after rails conventions, this should except instead of returning nil
    unit_data.nil? ? nil : new(unit_data)
  end

  def self.find_by(name: nil, force: false)
    raise "Invalid name #{name}" unless name.present? && name =~ /^[\w-]+$/

    unit_data = APIUnitGetter.call(id: name, force: force)
    unit_data.nil? ? nil : new(unit_data)
  end

  def initialize(data)
    @id = data['id']
    @name = data['name']
    @label = data['labelfr']
    @name_fr = data['name']
    @name_en = data['nameen']
    @name_de = data['namede']
    @name_it = data['nameid']
    @label_fr = data['labelfr']
    @label_en = data['labelen']
    @label_de = data['labelde']
    @label_it = data['labelid']
    @kind = data['type']
    @resp_id = data['responsibleid']
    # @type = data['unittype']['label']
    @url = data['url']
    @direct_children_ids = data['directchildren'].split(",").map(&:to_i)
    @all_children_ids = data['allchildren'].split(",").map(&:to_i)
    fix_for_reorg21(data)
    @address = Address.new(
      'unitid' => @id,
      'country' => data['country'],
      'hierarchy' => @hierarchy,
      'part1' => data['address1'],
      'part2' => data['address2'],
      'part3' => data['address3'],
      'part4' => data['address4'],
      'city' => data['city']
    )
  end

  def member_scipers
    json = APIPersonGetter.call(unitid: id)
    json.present? ? json.map { |p| p['id'] }.uniq : []
  end

  # The units have been partially reorganized from 4 to 5 level.
  # After some reverse engineering I conclude that this concerns only the units
  # of type EPFL VPx. Example unit 13030 which is shown by api as
  # EPFL VPO-SI ISAS ISAS-FSD should read EPFL VPO VPO-SI ISAS ISAS-FSD instead
  # This function fixes it.
  # The parent of a level 2 unit (e.g. VPO-SI) is EPFL. Instead it is actually a
  # level 3 unit and its parent is VPO (level 2) instead. Therefore, the parentid
  # provided by api is wrong and the only way of fixing it is by looking at the
  # parent unit name.
  VPLEVEL2 = {
    "VPI" => 10_012,
    "VPO" => 10_046,
    "VPF" => 13_367,
    "VPA" => 13_876,
    "VPH" => 13_928,
    "VPS" => 14_518,
  }.freeze
  def fix_for_reorg21(data)
    h21 = data['path'].split(" ")
    @level = h21.count
    @parent_id = data['parentid']
    if h21[1] =~ /^VP.-/
      vp = h21[1].split("-").first
      h21.insert(1, vp)
      @level += 1
      @parent_id = VPLEVEL2[vp] if @level == 3
    end
    @hierarchy = h21.join(" ")
  end

  def parent
    @parent ||= Unit.find(@parent_id)
  end

  def direct_children
    @direct_children ||= @direct_children_ids.map { |id| Unit.find(id) }
  end

  def all_children
    @all_children ||= @all_children_ids.map { |id| Unit.find(id) }
  end

  def <=>(other)
    level <=> other.level
  end
end
