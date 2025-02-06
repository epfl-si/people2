# frozen_string_literal: true

class Group
  attr_reader :id, :name, :description, :gid

  def self.find(id)
    raise "Invalid id #{id}" if id.to_i.zero?

    group_data = APIGroupGetter.call(id: id)
    # TODO: after rails conventions, this should except instead of returning nil
    group_data.nil? ? nil : new(group_data)
  end

  def self.find_by(name: nil, force: false)
    raise "Invalid name #{name}" unless name.present? && name =~ /^[\w-]+$/

    group_data = APIGroupGetter.call(id: name, force: force)
    group_data.nil? ? nil : new(group_data)
  end

  def initialize(data)
    @id = data['id']
    @name = data["name"]
    @description = data["description"]
    @gid = data["gid"]
  end
end
