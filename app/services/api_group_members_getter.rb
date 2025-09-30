# frozen_string_literal: true

class APIGroupMembersGetter < APIBaseGetter
  def initialize(data = {})
    @id = data.delete(:id)
    @resource = "members"
    @params = []

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
