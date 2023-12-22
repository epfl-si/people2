# frozen_string_literal: true

class Position
  attr_reader :id, :label_en, :label_frm, :label_fri, :label_frf

  include Translatable
  inclusively_translates :label

  def initialize(h)
    @id = h['id']
    @label_en = h['labelen']
    @label_frm = h['labelfr']
    @label_fri = h['labelinclusive']
    @label_frf = h['labelxx']
  end
end
