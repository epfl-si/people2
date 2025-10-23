# frozen_string_literal: true

class APIGroupMembersGetter < APIBaseGetter
  def initialize(data = {})
    @id = data.delete(:id)
    @resource = "members"
    @params = [
      # search(string): search on members name to get only matching members
      :search,
      # expandgroups(integer): calculate the list of direct members of each member of type 'group'
      :expandgroups,
      # expandothers(integer): calculate the list of members of each member of type 'unit' and 'list'
      :expandothers,
      # reursive(integer): get all members of the group recursively
      :recursive,
      # pageindex(int) defaults to 0
      :pageindex,
      # pagesize(int) defaults to 100
      :pagesize,
      :sortcolumn,
      :sortdirection
    ]

    super(data)
  end

  def path
    "groups/#{@id}/members"
  end

  # def dofetch
  #   r = super
  #   r.nil? ? r : r.index_by { |h| h['name'] }
  # end
end
