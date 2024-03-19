# {
#   "address": { ... },
#   "hierarchie": "EPFL VPO-SI ISAS ISAS-FSD",
#   "ordre": 1,
#   "phones": [
#     { ... },
#     { ... }
#   ],
#   "rooms": [
#     { ... },
#     { ... }
#   ],
#   "sigle": "ISAS-FSD"
# }
class Atela::Accred
  attr_reader :address, :hierarchy, :order, :phones, :rooms

  def initialize(data)
    @unit = nil
    @address = Atela::Address.new(data['address'])
    @phones = data['phones'].present? ? data['phones'].map{|d| Atela::Phone.new(d)} : []
    @hierarchy = data['hierarchie']
    @order = data['ordre']
    @rooms = data.key?('rooms') ? data['rooms'].map{|d| Atela::Room.new(d)} : []
  end
  def unit=(u)
    @unit = u
  end
end
