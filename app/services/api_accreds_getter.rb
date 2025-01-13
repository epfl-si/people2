# frozen_string_literal: true

# TODO: ask IAM for missing class delegate (done, waiting)

class APIAccredsGetter < APIBaseGetter
  def initialize(data = {})
    @resource = "accreds"
    @idname = :sciper
    @params = [
      # classid(int): id of the class
      # Example : 4
      :classid,
      # pageindex(int) 0 by default
      :pageindex,
      # pagesize(int) 100 by default
      :pagesize,
      # persid(sciper list): scipers of persons
      :persid,
      # positionid(int): id of the position
      # Example : 852
      :positionid,
      # sortcolumn(str): field to sort on
      # Example : "person"
      :sortcolumn,
      # sortdirection(str): asc, desc
      :sortdirection,
      # statusid(int): id of the status
      # Example : 1
      :statusid,
      # unitid(str): id of the unit
      # Example : 14290
      :unitid
    ]
    super(data)
  end

  def self.for_sciper(sciper)
    new(persid: sciper)
  end

  def self.for_sciper_and_unit(sciper, unit_id)
    new(persid: sciper, unitid: unit_id)
  end

  def self.for_status(status_id)
    new(statusid: status_id)
  end
end
