# frozen_string_literal: true

# This class represents a person as described by api.epfl.ch
class Person
  attr_reader :data, :position

  private_class_method :new

  def initialize(person)
    @data = person
    @position = @data.delete('position')
    @position = Position.new(@position) unless @position.nil?
  end

  def self.find(sciper_or_email)
    g = if sciper_or_email.is_a?(Integer) || sciper_or_email =~ /^\d{6}$/
          APIPersonGetter.for_sciper(sciper_or_email)
        else
          APIPersonGetter.for_email(sciper_or_email)
        end
    p = g.fetch!
    new(p)
  end

  def display_name
    @display_name ||= "#{firstnameusual || firstname} #{lastnameusual || lastname}"
  end

  def sciper
    id
  end

  # Methods that are not explicitly defined are assumed to be keys of @data
  # Fields that are expected to be always present will except if not found
  def method_missing(key, *args, &blk)
    @data.key?(key.to_s) ? @data[key.to_s] : super
  end

  def respond_to_missing?(key, include_private = false)
    @data.key?(key.to_s) || super
  end

  # Optional fields when not present will get a nil value without failing
  %w[firstnameusual lastnameusual].each do |m|
    define_method m.to_sym do
      @data[m]
    end
  end
end

# {
#   "account": {
#     "gecos": "string",
#     "gid": 0,
#     "home": "string",
#     "shell": "string",
#     "uid": 0,
#     "username": "string"
#   },
#   "addresses": [
#     {
#       "address": "string",
#       "country": "string",
#       "fromdefault": 0,
#       "part1": "string",
#       "part2": "string",
#       "part3": "string",
#       "part4": "string",
#       "part5": "string",
#       "postal": {
#         "part1": "string",
#         "part2": "string",
#         "part3": "string",
#         "part4": "string",
#         "part5": "string"
#       },
#       "roomunitid": 0,
#       "type": "string",
#       "typerelatedid": 0,
#       "unitid": "string"
#     }
#   ],
#   "automap": {
#     "path": "string",
#     "protocol": "string",
#     "security": "string",
#     "server": "string"
#   },
#   "camipro": {
#     "biblioid": "string",
#     "cardid": "string",
#     "cardstatus": "string",
#     "emissiondate": "string",
#     "persstatus": "string",
#     "statedate": "string"
#   },
#   "display": "string",
#   "email": "string",
#   "firstname": "string",
#   "firstnameuc": "string",
#   "firstnameus": "string",
#   "firstnameusual": "string",
#   "gender": "string",
#   "id": "string",
#   "lastname": "string",
#   "lastnameuc": "string",
#   "lastnameus": "string",
#   "lastnameusual": "string",
#   "name": "string",
#   "nameus": "string",
#   "org": "string",
#   "phones": [
#     {
#       "fromdefault": 0,
#       "hidden": 0,
#       "id": 0,
#       "number": "string",
#       "order": 0,
#       "roomid": 0,
#       "roomname": "string",
#       "unitid": "string"
#     }
#   ],
#   "physemail": "string",
#   "position": {
#     "labelen": "string",
#     "labelfr": "string",
#     "labelinclusive": "string",
#     "labelxx": "string"
#   },
#   "rooms": [
#     {
#       "externalroomid": 0,
#       "fromdefault": 0,
#       "hidden": 0,
#       "id": 0,
#       "name": "string",
#       "order": 0,
#       "unitid": "string"
#     }
#   ],
#   "sciper": "string",
#   "sex": "string",
#   "status": "string",
#   "studies": [
#     {
#       "accredunitid": 0,
#       "branch1": "string",
#       "branch3": "string",
#       "matricule": "string",
#       "sciper": "string",
#       "studylevel": "string"
#     }
#   ],
#   "type": "string",
#   "uid": 0,
#   "upfirstname": "string",
#   "upname": "string",
#   "username": "string"
# }
