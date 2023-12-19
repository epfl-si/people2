# frozen_string_literal: true

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
module Atela
  class Phone
    attr_reader :id, :order, :category, :number

    def initialize(data)
      @id = data['phone_id']
      @number = data['phone_nb']
      @order = data['phone_order'].to_i
      @category = data['phone_type']
      @hidden = data['phone_hidden'].to_i != 0
    end

    def hidden?
      @hidden
    end
  end
end
