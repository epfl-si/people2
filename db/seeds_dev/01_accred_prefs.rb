# frozen_string_literal: true

# TODO: setting this aside. We will take care of finding a good way of
#   migrating the old accred preferences. We will need to
#   1. produce one accred foreach actual accreditation
#   2. decide how to sort the accreds that do not have a legacy accred pref
# Profile.all.find_each do |profile|
#
#   Legacy::AccredPref.for_sciper(profile.sciper).each do |ap|
#     profile.accreds.create(
#       sciper: profile.sciper,
#       unit_id: ap.unit,
#       position: ap.ordre,
#       hidden: ap.hidden?,
#       hidden_addr: ap.hidden_addr?
#     )
#   end
# end
