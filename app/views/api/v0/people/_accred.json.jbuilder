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
json.adresse     accred.unit.address.full
json.fonction_en accred.position.t_label(gender, 'en')
json.fonction_fr accred.position.t_label(gender, 'fr')
json.hierarchie  accred.unit.hierarchy
json.id_unite    accred.unit.id
json.status      accred.t_status_label('en')
json.status_en   accred.t_status_label('en')
json.status_fr   accred.t_status_label('fr')
json.order       order + 1
# json.sigle       accred.unit.t_name('fr')
json.sigle       accred.unit_name
json.rooms       room&.name || ""
