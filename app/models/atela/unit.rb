# frozen_string_literal: true

# {
#   "address": {
#     "line1": "EPFL VPO-SI ISAS-FSD",
#     "line2": "INN 012 (Bâtiment INN)",
#     "line3": "Station 14",
#     "line4": "CH-1015 Lausanne",
#     "line5": ""
#   },
#   "id": 13030,
#   "label": "Développement Full-Stack",
#   "level": 4,
#   "sigle": "ISAS-FSD"
# }
module Atela
  class Unit
    attr_reader :id, :label, :level, :name

    def initialize(data)
      @id = data['id']
      @label = data['label']
      @level = data['level']
      @name = data['sigle']
    end
  end
end
