# frozen_string_literal: true

class BulkAccred < OpenStruct
  include Translatable
  translates :position, :status_label

  def initialize(data)
    super(data.merge({
                       position_it: data[:position_en],
                       position_de: data[:position_en],
                       status_label_it: data[:status_label_en],
                       status_label_de: data[:status_label_en],
                     }))
  end

  def room_names
    rooms&.reject(&:hidden?)&.map(&:name) || []
  end

  def phone_numbers
    phones&.reject(&:hidden?)&.map(&:number) || []
  end
end
