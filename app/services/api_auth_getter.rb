# frozen_string_literal: true

# curl --basic --user 'people:xxx' -X GET \
# 'https://api.epfl.ch/v1/authorizations?type=property&authid=gestprofil&persid=121769&status=active'
class APIAuthGetter < APIBaseGetter
  def initialize(data = {})
    @resource = "authorizations"
    @idname = :sciper
    @params = [
      # alldata(int): include person and resource data
      :alldata,
      # attribution(str):
      # Example : 'explicit', 'role', 'default', 'status', 'forbidden', 'deputy'
      :attribution,
      # authid(str list): ids or names of the rights/roles/statuses/properties
      # Example : 'accreditation' or 1
      :authid,
      # expand(int): include child resource in result calculation
      :expand,
      # format(str): format of the output, empty value will give a list of plain
      # authorizations object, 'map' will give a map quite similar to websrv
      # output, 'mapname' will replace the authid by its name
      :format,
      # mode(str): mode (usually calling screen in frontend). Example : "audit"
      :mode,
      # nodep(int): don't include authorizations obtained by a deputation
      :nodep,
      # onpersid(sciper list): scipers of persons on which the specified
      # authorizations apply ('authid' field must be provided)
      :onpersid,
      # persid(sciper list): scipers of persons
      :persid,
      # refdate(YYYY-MM-DD): data reference date in format
      :refdate,
      # resid(list): resource IDs (unit, CF, fund)
      # Example : unit "13630", CF "FC1028", fund "FF1921-1"
      :resid,
      # state(str): is a meta-status of authorization, 'active' gives all the
      # active authorizations (with status active, toreval, toxtend, extendrequested,
      # deleterequested), empty value gives everything
      # Example : 'active'
      :state,
      # status(str): status of authorization
      # Example : 'active', 'canceled', 'toreval', 'toextend', 'extendrequested', 'addrequested'
      :status,
      # type(str): type of authorization
      # Example: 'status', 'property', 'right', 'role'
      :type
    ]
    data = {
      authid: 'gestprofil', # 'botweb',
      type: 'property',
      status: 'active',
    }.merge(data)

    super(data)
  end
end
