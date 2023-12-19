# frozen_string_literal: true

# {
#   "description": "Bureau",
#   "from_default": "true",
#   "room_abr": "INN 014",
#   "room_hidden": "0",
#   "room_id": 31559,
#   "room_order": 1,
#   "type": "internal"
# },
module Atela
  class Room
    attr_reader :id, :description, :abbr, :order, :category

    def initialize(data)
      @id = data['room_id']
      @description = data['description']
      @abbr = data['room_abr']
      @order = data['room_order'].to_i
      @category = data['type']
      @hidden = data['room_hidden'].to_i != 0
    end

    def label
      @abbr
    end

    # TODO: use config variable for EPFL plan base address
    def url
      # "https://plan.epfl.ch/?"+@abbr.to_query(:room)
      "https://plan.epfl.ch/?room=#{@abbr.gsub(' ', '%20')}"
    end

    def hidden?
      @hidden
    end
  end
end
