# person: {
#   "firstname": "Giovanni",
#   "name": "Cangiani",
#   "pers_id": 121769,
#   "username": "cangiani"
# },
# accreds: {...},              -> @accreds
# units: [{...},{...}],
# default_phone: {...},        -> @phone
# default_room: {...},         -> @room
class Atela::Person
  attr_reader :first_name, :family_name, :sciper, :username, :phone, :room, :accreds

  MAX_ATTEMPTS = 1
  def initialize(sciper)
    @sciper = sciper
    @accreds = {}
    @first_name = "NA"
    @family_name = "NA"
    @username = "NA"
    @phone = nil
    @room = nil

    data = load(sciper)

    if data.nil?
      Rails.logger.warn("failed to find Atela data for sciper #{sciper}")
    else
      parse(data)
    end
  end

  def sorted_accreds
    @accreds.values.sort { |a, b| a.order <=> b.order }
  end

  def display_name
    @first_name + " " + @family_name
  end

  private

  def load(sciper)
    @attempts ||= 0
    return nil if @attempts >= MAX_ATTEMPTS

    @attempts += 1
    AtelaAccredsGetter.call(sciper) || nil
  end

  def parse(data)
    if d = data['person']
      @first_name = d['firstname']
      @family_name = d['name']
      @username = d['username']
    else
      Rails.logger.error("Data from Atela for #{@sciper} does not contain minimal person data")
    end
    units = {}
    if d = data['units']
      # units = d.map{|u| AtelaUnit.new(d)}.map{|u| [u.id, u]}.to_h
      d.each do |ud|
        u = Atela::Unit.new(ud)
        units[u.id] = u
      end
    end
    if d = data['accreds']
      d.each do |k, v|
        a = Atela::Accred.new(v)
        u = units[k]
        a.unit = u unless u.nil?
        @accreds[k] = a
      end
    end
    if d = data['default_phone']
      @phone = Atela::Phone.new(d)
    end
    return unless d = data['default_room']

    @room = Atela::Room.new(d)
  end
end

# Example output from atela_backend:

# # ---------------------------------------------------------------- For me 121769
# {
#   "accreds": {
#     "13030": {
#       "address": {
#         "adr": "EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne",
#         "cmd_id": 796438,
#         "line1": "EPFL SI IDEV-FSD",
#         "line2": "INN 012 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": "",
#         "pays": "Suisse",
#         "pers_id": 121769,
#         "room_unit_id": "",
#         "type": "custom",
#         "type_related_id": "0",
#         "unit_id": 13030,
#         "valid_from": "2021-08-11 09:13:17",
#         "valid_to": "",
#         "value": "EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
#       },
#       "hierarchie": "EPFL VPO-SI ISAS ISAS-FSD",
#       "ordre": 1,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "NATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 3971,
#           "phone_nb": "+41216937526",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "rooms": [
#         {
#           "description": "Bureau",
#           "from_default": "true",
#           "room_abr": "INN 014",
#           "room_hidden": "0",
#           "room_id": 31559,
#           "room_order": 1,
#           "type": "internal"
#         }
#       ],
#       "sigle": "ISAS-FSD"
#     }
#   },
#   "default_phone": {
#     "from_default": "true",
#     "other_room": "",
#     "outgoing_right": "NATIONAL",
#     "phone_hidden": "0",
#     "phone_id": 3971,
#     "phone_nb": "+41216937526",
#     "phone_order": 1,
#     "phone_type": "FIXE_OFFICE",
#     "room_id": ""
#   },
#   "default_room": {
#     "description": "Bureau",
#     "from_default": "true",
#     "room_abr": "INN 014",
#     "room_hidden": "0",
#     "room_id": 31559,
#     "room_order": 1,
#     "type": "internal"
#   },
#   "person": {
#     "firstname": "Giovanni",
#     "name": "Cangiani",
#     "pers_id": 121769,
#     "username": "cangiani"
#   },
#   "units": [
#     {
#       "address": {
#         "line1": "EPFL VPO-SI ISAS-FSD",
#         "line2": "INN 012 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 13030,
#       "label": "Développement Full-Stack",
#       "level": 4,
#       "sigle": "ISAS-FSD"
#     }
#   ]
# }

# # For --------------------------------------------------------- Edouard (229105)
# {
#   "accreds": {
#     "10755": {
#       "address": {},
#       "hierarchie": "EPFL VPA-AVP-PGE AVP-PGE-EDOC EDIC-GE",
#       "ordre": 5,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "sigle": "EDIC-GE"
#     },
#     "11017": {
#       "address": {},
#       "hierarchie": "EPFL IC IC-SIN SIN-ENS",
#       "ordre": 2,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "sigle": "SIN-ENS"
#     },
#     "11018": {
#       "address": {},
#       "hierarchie": "EPFL IC IC-SSC SSC-ENS",
#       "ordre": 4,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "sigle": "SSC-ENS"
#     },
#     "12634": {
#       "address": {
#         "adr": "EPFL IC IINFCOM DCSL $ INN 237 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne",
#         "cmd_id": 874438,
#         "line1": "EPFL IC IINFCOM DCSL",
#         "line2": "INN 237 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": "",
#         "pays": "Suisse",
#         "pers_id": 229105,
#         "room_unit_id": "",
#         "type": "custom",
#         "type_related_id": "",
#         "unit_id": 12634,
#         "valid_from": "2020-04-27 11:19:43",
#         "valid_to": "",
#         "value": "EPFL IC IINFCOM DCSL $ INN 237 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
#       },
#       "hierarchie": "EPFL IC IINFCOM DCSL",
#       "ordre": 1,
#       "phones": [
#         {
#           "from_default": "false",
#           "other_room": "",
#           "outgoing_right": "NATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5239,
#           "phone_nb": "+41216937997",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         },
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 2,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "rooms": [
#         {
#           "description": "Bureau",
#           "from_default": "false",
#           "room_abr": "INN 237",
#           "room_hidden": "0",
#           "room_id": 4260,
#           "room_order": 1,
#           "type": "internal"
#         }
#       ],
#       "sigle": "DCSL"
#     },
#     "13301": {
#       "address": {
#         "adr": "EPFL SDSC $ INN 218 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne",
#         "cmd_id": "0",
#         "line1": "EPFL SDSC",
#         "line2": "INN 218 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": "",
#         "pays": "Suisse",
#         "pers_id": 229105,
#         "room_unit_id": "",
#         "type": "unit",
#         "type_related_id": 13301,
#         "unit_id": 13301,
#         "valid_from": "2020-04-27 11:19:43",
#         "valid_to": "",
#         "value": "EPFL SDSC $ INN 218 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
#       },
#       "hierarchie": "EPFL VPA-AVP-CP SDSC SDSC-GE",
#       "ordre": 3,
#       "phones": [
#         {
#           "from_default": "false",
#           "other_room": "",
#           "outgoing_right": "NATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 3710,
#           "phone_nb": "+41216934388",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         },
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 2,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "rooms": [
#         {
#           "description": "Bureau",
#           "from_default": "false",
#           "room_abr": "INN 237",
#           "room_hidden": "0",
#           "room_id": 4260,
#           "room_order": 1,
#           "type": "internal"
#         }
#       ],
#       "sigle": "SDSC-GE"
#     },
#     "13377": {
#       "address": {},
#       "hierarchie": "EPFL VPA-AVP-PGE AVP-PGE-EDOC CDOCT",
#       "ordre": 6,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "sigle": "CDOCT"
#     },
#     "14293": {
#       "address": {},
#       "hierarchie": "EPFL VPA-AVP-CP RCP RCP-GE",
#       "ordre": 7,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "INTERNATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 5809,
#           "phone_nb": "+41216934707",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "sigle": "RCP-GE"
#     }
#   },
#   "default_phone": {
#     "from_default": "true",
#     "other_room": "",
#     "outgoing_right": "INTERNATIONAL",
#     "phone_hidden": "0",
#     "phone_id": 5809,
#     "phone_nb": "+41216934707",
#     "phone_order": 1,
#     "phone_type": "FIXE_OFFICE",
#     "room_id": ""
#   },
#   "person": {
#     "firstname": "Edouard",
#     "name": "Bugnion",
#     "pers_id": 229105,
#     "username": "ebugnion"
#   },
#   "units": [
#     {
#       "address": {
#         "line1": "EPFL IC IINFCOM DCSL",
#         "line2": "INN 311 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 12634,
#       "label": "Laboratoire des systèmes de centres de calcul",
#       "level": 4,
#       "sigle": "DCSL"
#     },
#     {
#       "address": {
#         "line1": "EPFL IC SIN-GE",
#         "line2": "INN 112 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 11017,
#       "label": "SIN - Enseignement",
#       "level": 4,
#       "sigle": "SIN-ENS"
#     },
#     {
#       "address": {
#         "line1": "EPFL SDSC",
#         "line2": "INN 218 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 13301,
#       "label": "SDSC - Gestion",
#       "level": 4,
#       "sigle": "SDSC-GE"
#     },
#     {
#       "address": {
#         "line1": "EPFL IC SSC-GE",
#         "line2": "INR 130 (Bâtiment INR)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 11018,
#       "label": "SSC - Enseignement",
#       "level": 4,
#       "sigle": "SSC-ENS"
#     },
#     {
#       "address": {
#         "line1": "EPFL AVP-PGE EDIC-GE",
#         "line2": "INN 134 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 10755,
#       "label": "Programme doctoral Informatique et Communications",
#       "level": 4,
#       "sigle": "EDIC-GE"
#     },
#     {
#       "address": {
#         "line1": "EPFL AVP-PGE CDOCT",
#         "line2": "CE 1 631 (Centre Est)",
#         "line3": "Station 1",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 13377,
#       "label": "Commission doctorale",
#       "level": 4,
#       "sigle": "CDOCT"
#     },
#     {
#       "address": {
#         "line1": "EPFL AVP-RCP GE",
#         "line2": "BI A2 397 (Bâtiment BI)",
#         "line3": "Station 7",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 14293,
#       "label": "Research computing - Gestion",
#       "level": 4,
#       "sigle": "RCP-GE"
#     }
#   ]
# }

# # ------------------------------------------------------- For Christian (106785)
# {
#   "accreds": {
#     "12548": {
#       "address": {
#         "adr": "Musée Bolo $ EPFL - Bâtiment INF $ Station 14 $ CH-1015 Lausanne",
#         "cmd_id": 852837,
#         "line1": "Musée Bolo",
#         "line2": "EPFL - Bâtiment INF",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": "",
#         "pays": "Suisse",
#         "pers_id": 106785,
#         "room_unit_id": "",
#         "type": "unit",
#         "type_related_id": 12548,
#         "unit_id": 12548,
#         "valid_from": "2021-10-20 18:21:21",
#         "valid_to": "",
#         "value": "Musée Bolo $ EPFL - Bâtiment INF $ Station 14 $ CH-1015 Lausanne"
#       },
#       "hierarchie": "EHE FOND-PART FOND-SUBVENT FMI-BOLO",
#       "ordre": 2,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "NATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 3680,
#           "phone_nb": "+41216934598",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "rooms": [
#         {
#           "description": "Bureau",
#           "from_default": "true",
#           "room_abr": "INN 014",
#           "room_hidden": "0",
#           "room_id": 31559,
#           "room_order": 1,
#           "type": "internal"
#         }
#       ],
#       "sigle": "FMI-BOLO"
#     },
#     "13030": {
#       "address": {
#         "adr": "EPFL VPO-SI ISAS-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne",
#         "cmd_id": 979083,
#         "line1": "EPFL VPO-SI ISAS-FSD",
#         "line2": "INN 012 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": "",
#         "pays": "Suisse",
#         "pers_id": 106785,
#         "room_unit_id": "",
#         "type": "unit",
#         "type_related_id": 13030,
#         "unit_id": 13030,
#         "valid_from": "2022-02-10 13:16:44",
#         "valid_to": "",
#         "value": "EPFL VPO-SI ISAS-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
#       },
#       "hierarchie": "EPFL VPO-SI ISAS ISAS-FSD",
#       "ordre": 1,
#       "phones": [
#         {
#           "from_default": "true",
#           "other_room": "",
#           "outgoing_right": "NATIONAL",
#           "phone_hidden": "0",
#           "phone_id": 3680,
#           "phone_nb": "+41216934598",
#           "phone_order": 1,
#           "phone_type": "FIXE_OFFICE",
#           "room_id": ""
#         }
#       ],
#       "rooms": [
#         {
#           "description": "Bureau",
#           "from_default": "true",
#           "room_abr": "INN 014",
#           "room_hidden": "0",
#           "room_id": 31559,
#           "room_order": 1,
#           "type": "internal"
#         }
#       ],
#       "sigle": "ISAS-FSD"
#     }
#   },
#   "default_phone": {
#     "from_default": "true",
#     "other_room": "",
#     "outgoing_right": "NATIONAL",
#     "phone_hidden": "0",
#     "phone_id": 3680,
#     "phone_nb": "+41216934598",
#     "phone_order": 1,
#     "phone_type": "FIXE_OFFICE",
#     "room_id": ""
#   },
#   "default_room": {
#     "description": "Bureau",
#     "from_default": "true",
#     "room_abr": "INN 014",
#     "room_hidden": "0",
#     "room_id": 31559,
#     "room_order": 1,
#     "type": "internal"
#   },
#   "person": {
#     "firstname": "Christian",
#     "name": "Zufferey",
#     "pers_id": 106785,
#     "username": "czufferey"
#   },
#   "units": [
#     {
#       "address": {
#         "line1": "EPFL VPO-SI ISAS-FSD",
#         "line2": "INN 012 (Bâtiment INN)",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 13030,
#       "label": "Développement Full-Stack",
#       "level": 4,
#       "sigle": "ISAS-FSD"
#     },
#     {
#       "address": {
#         "line1": "Musée Bolo",
#         "line2": "EPFL - Bâtiment INF",
#         "line3": "Station 14",
#         "line4": "CH-1015 Lausanne",
#         "line5": ""
#       },
#       "id": 12548,
#       "label": "Fondation Mémoires Informatiques (Musée Bolo)",
#       "level": 4,
#       "sigle": "FMI-BOLO"
#     }
#   ]
# }
