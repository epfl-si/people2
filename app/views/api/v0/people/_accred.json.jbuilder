# frozen_string_literal: true

#       "12170": {
#         "adresse": "EPFL ENAC IIC EESD $ GC B2 505 (Bâtiment GC) $ Station 18 $ 1015 Lausanne",
#         "fonction_en": "Secretary",
#         "fonction_fr": "Secrétaire",
#         "hierarchie": "EPFL ENAC IIC EESD",
#         "id_unite": 12170,
#         "rooms": "GC B2 505",
#         "sigle": "EESD",
#         "statut": "Staff"
#         "ordre": 1,
#         "phones": [
#           35706,
#           ""
#         ],
#       },
json.id_unite    accred.unit.id || ""
json.sigle       accred.unit.name || ""
json.hierarchie  accred.unit.path || ""
# json.adresse     accred.unit.address || ""

json.fonction    accred.t_position&.strip || ""
json.fonction_en accred.position_en&.strip || ""
json.fonction_fr accred.position_fr&.strip || ""

json.statut      accred.t_status_label || ""
json.status_en   accred.t_status_label('en') || ""
json.status_fr   accred.t_status_label('fr') || ""

json.rooms       accred.room_names&.first || ""
json.phones      accred.phone_numbers

json.ordre       ext_order
