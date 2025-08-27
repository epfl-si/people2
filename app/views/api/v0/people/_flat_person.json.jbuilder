# frozen_string_literal: true

#         "email": "ciccio.pasticcio@epfl.ch",
#         "nom": "Pasticcio",
#         "prenom": "Beat",
#         "sciper": 123456,
#         "adresse": "EPFL SB ISIC LCBM $ CH B3 485 (Bâtiment CH) $ Station 6 $ 1015 Lausanne",
#         "rooms": "CH B3 485",
#         "statut": "Staff"
#         "fonction_en": "Associate Professor",
#         "fonction_fr": "Professeur associé",
#         "hierarchie": "EPFL SB ISIC LCBM",
#         "sigle": "LCBM",
#         "id_unite": 12345,

#         "ordre": 1,
#         "people": {
#           "photo_show": 1,
#           "photo_url": "https://people.epfl.ch/private/common/photos/links/123456.jpg",
#           "sciper": 123456,
#           "titre": ""
#         },
#         "phones": [
#           "+41 21 693 12 34",
#           "+41 21 693 43 21"
#         ],

json.email        person.public_email
json.nom          person.name.display_last
json.prenom       person.name.display_first
json.sciper       person.sciper
a = person.default_address
if a.present?
  json.adresse    a.full
  json.hierarchie a.hierarchy
  json.id_unite   a.unit_id
  json.sigle      a.hierarchy.split(" ").last
end
# json.rooms        person.rooms&.map{|r| r.name}&.join(",") || ""
json.rooms        person.rooms&.first&.name || ""
json.status       person.status || ""
json.fonction_en  person.position!&.t_label(person.gender, 'en')
json.fonction_fr  person.position!&.t_label(person.gender, 'fr')
json.phones       person.phones&.map(&:number)&.uniq || []
if profile.present?
  json.partial! 'profile', profile: profile
end
