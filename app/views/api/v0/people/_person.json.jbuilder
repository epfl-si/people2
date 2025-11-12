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

json.email person.public_email || ""
json.people_url person_url(sciper_or_name: person.slug)
json.prenom person.firstname || ""
json.nom person.lastname || ""
json.sciper person.sciper.to_i
profile = person.profile
if profile.present?
  json.people do
    json.partial! 'profile', profile: profile
  end
end
json.unites do
  # TODO: WP only uses the first accred. Should we just return that one ?
  # accred = person.accreds.sort{|a,b| a.order}.first
  person.accreds.each do |accred|
    json.set! accred.unit_id do
      json.partial! 'accred', accred: accred
    end
  end
end
