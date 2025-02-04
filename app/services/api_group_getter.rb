# frozen_string_literal: true

class APIGroupGetter < APIBaseGetter
  def initialize(data = {})
    @resource = "groups"
    # @idname = :ids
    @params = [
      # ids(str list): IDs of groups to retrieve e.g. "S01234,S12345"
      :ids,
      # name(str): name of group (e.g. ATELA)
      :name,
      # owner(sciper): sciper of the owner of the group
      :owner,
      # admin(sciper): sciper of (one of) the admins of the group
      :admin,
      # member(sciper): sciper of (one of) the members of the group
      :member,
      # format(string): csv|legacy default to json
      :format,
      # pageindex(int) defaults to 0
      :pageindex,
      # pagesize(int) defaults to 100
      :pagesize,
      :sortcolumn,
      :sortdirection
    ]
    super(data)
  end
end
