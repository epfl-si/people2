# frozen_string_literal: true

#         "email": "ciccio.pasticcio@epfl.ch",
#         "nom": "Pasticcio",
#         "prenom": "Beat",
#         "sciper": 123456,

#         "adresse": "EPFL SB ISIC LCBM $ CH B3 485 (Bâtiment CH) $ Station 6 $ 1015 Lausanne",
#         "rooms": "CH B3 485",
#         "sigle": "LCBM",
#         "statut": "Staff"
#         "fonction_en": "Associate Professor",
#         "fonction_fr": "Professeur associé",
#         "hierarchie": "EPFL SB ISIC LCBM",
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

json.email  person.public_email
json.nom    person.name.display_last
json.prenom person.name.display_first
json.sciper person.sciper

# json.people do
#   if profile.present?
#     json.sciper     profile.sciper
#     json.photo_show profile.show_photo? ? 1 : 0
#     json.photo_url "TODO" if profile.show_photo?
#     if profile.personal_web_url.present? && profile.show_weburl?
#       json.web_perso  profile.personal_web_url
#     else
#       json.web_perso  ""
#     end
#     # TODO: after #44
#     # json.expertise ... this is now a translated rich text box.
#   end
# end
# json.unites do
#   person.accreditations.select(&:visible?).sort.each_with_index do |accred, order|
#     json.set! accred.unit_id do
#       json.partial! 'accred', accred: accred, gender: person.gender, order: order, room: person.room(accred.unit_id)
#     end
#   end
# end
