# frozen_string_literal: true

# {
#   "adr": "EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne",
#   "cmd_id": 796438,
#   "line1": "EPFL SI IDEV-FSD",
#   "line2": "INN 012 (Bâtiment INN)",
#   "line3": "Station 14",
#   "line4": "CH-1015 Lausanne",
#   "line5": "",
#   "pays": "Suisse",
#   "pers_id": 121769,
#   "room_unit_id": "",
#   "type": "custom",
#   "type_related_id": "0",
#   "unit_id": 13030,
#   "valid_from": "2021-08-11 09:13:17",
#   "valid_to": "",
#   "value": "EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
# },
module Atela
  class Address
    attr_reader :lines, :country, :category

    def initialize(data)
      @full = data['adr']
      @lines = [data['line1'], data['line2'], data['line3'], data['line4'], data['line5']]
      @category = data['type']
      @country = data['pays']
      @unit_id = data['unit_id']
      @valid_from = datetime_or_nil(data['valid_from'])
      @valid_to = datetime_or_nil(data['valid_to'])
    end

    def full
      @full || @lines.join(' $ ')
    end

    # don't use valid? to avoid confusion with AR::valid? that implies validation
    def enabled?
      return false if @valid_from.nil?

      t = DateTime.now
      return @valid_from < t if @valid_to.nil?

      (@valid_from < t) && (t < @valid_to)
    end

    private

    def datetime_or_nil(s)
      begin
        d = DateTime.strptime(s, '%Y-%m-%d %H:%M:%S')
      rescue StandardError
        d = nil
      end
      d
    end
  end
end
