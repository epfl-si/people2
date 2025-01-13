# frozen_string_literal: true

# TODO: ask IAM for missing field Matricule SAP (numsap)
# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class APIPersonGetter < APIBaseGetter
  def initialize(data = {})
    @resource = "persons"
    @idname = :sciper
    @params = [
      # firstname(str): firstname of the person
      :firstname,
      # lastname(str): lastname of the person
      :lastname,
      # query(str): for generic search on any field
      # (firstname, lastname, usual firstname, usual lastname, sciper, email, username)
      :query, :email,
      # persid(str list): id of one or many persons
      :persid,
      # unitid(int list): id of one or many units where persons are accredited
      :unitid,
      # isaccredited(int): to show only accredited persons, only usefull when not providing any unitid
      # example: 1
      :isaccredited,
      :pageindex,
      :pagesize,
      :sortcolumn,
      :sortdirection
    ]
    @alias = { email: "query" }
    super(data)
  end

  def fix_email(email)
    email.gsub(/@.*$/, '')
  end
end
