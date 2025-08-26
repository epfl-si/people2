# frozen_string_literal: true

#  "email": "ciccio.pasticcio@epfl.ch",
#  "nom": "Pasticcio",
#  "prenom": "Ciccio",
#  "sciper": 151960,
#  "people": {
#    "photo_show": 1,
#    "photo_url": "https://people.epfl.ch/private/common/photos/links/151960.jpg",
#    "sciper": 151960,
#    "expertise": "HPC, Algorithms, Networking, Programming..."
#    "web_perso": "https://slideshot.epfl.ch/"
#  },
#  "unites": {
#    "12170": { ... ACCRED DATA (see _accred.json.jbuilder) ... },
#    "10203": { ... },
#    "12325": { ... },
#  }
# }

json.email  person.public_email
json.nom    person.name.display_last
json.prenom person.name.display_first
json.sciper person.sciper
if profile.present?
  json.people do
    json.partial! 'profile', profile: profile
  end
end
json.unites do
  person.accreditations.select(&:visible?).sort.each_with_index do |accred, order|
    json.set! accred.unit_id do
      json.partial! 'accred', accred: accred, gender: person.gender, order: order, room: person.room(accred.unit_id)
    end
  end
end
