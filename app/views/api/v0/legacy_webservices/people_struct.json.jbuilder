# frozen_string_literal: true

# Adding the struct parameter e.g. wsgetpeople/?units=LCBM&struct=1
# You get an array of dictionaries instead.
# Since an unit is given as input, there is no units lising and the
# corresponding data (`ordre`, `sigle`, `hierarchie`, `id_unite`) is added
# directly in the member structure.
# [
#   {
#     "label": "Head of Laboratory",
#     "members": [
#       {
#         "adresse": "EPFL SB ISIC LCBM $ CH B3 485 (Bâtiment CH) $ Station 6 $ 1015 Lausanne",
#         "email": "ciccio.pasticcio@epfl.ch",
#         "nom": "Pasticcio",
#         "prenom": "Beat",
#         "rooms": "CH B3 485",
#         "sciper": 123456,
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
#       }
#     ]
#   },
#   {
#     "label": "Administrative staff",
#     "members": [
#       ...
#   }
# ]
