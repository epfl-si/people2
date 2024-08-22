# frozen_string_literal: true

# frozen_string_literal: true

# TODO: ask IAM for missing field Matricule SAP (numsap)
# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIUnitGetter < APIBaseGetter
  attr_accessor :url

  def initialize(data = {})
    @resource = "units"
    @params = [
      # format(str): format of the response, empty or 'legacy'
      :format,
      # ids(int list): list of units id
      :ids,
      # persid(str): sciper of person to get units where the person is accredited
      :persid,
      # query(str): search string on unit name or label
      :query, :name,
      :pageindex,
      :pagesize,
      :sortcolumn,
      :sortdirection
    ]
    @alias = { name: "query" }
    super(data)
  end

  # Units change very rarely. I expect many requests to arrive at the same time
  # therefore, I give to each one a different lifetime so that,
  # after the first time, they don't expire all together.
  def expire_in
    rand(600..700).hours
  end
end
