# frozen_string_literal: true

# The current json for one person: wsgetpeople/?scipers=123456
# ------------------------------------------------------------------------
# With scipers, units or groups given
#   wsgetpeople/?scipers=121769,116080
#   wsgetpeople/?units=LCBM
#   wsgetpeople/?groups=msiclab_ms
# you get a dictionary with scipers as keys
# and the following as content foreach sciper
# The key is the sciper number.
# {
#   "123456": {
#     ... PERSON DATA (see _person.json.jbuilder) ...
#   }
# }
people.each do |person|
  # TODO: what if it does not exist ?
  profiles[person.sciper]
  json.set! person.sciper.to_sym do
    json.partial! 'person', person: person
  end
end
