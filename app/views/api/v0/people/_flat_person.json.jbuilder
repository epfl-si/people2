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

json.email person.public_email || ""
json.people_url person_url(sciper_or_name: person.email_user)
json.prenom person.firstname || ""
json.nom    person.lastname || ""
json.sciper person.sciper.to_i

json.partial! 'accred', accred: person.accreds.first
profile = person.profile
json.partial! 'profile', profile: profile if profile.present?
