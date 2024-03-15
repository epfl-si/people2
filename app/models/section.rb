# frozen_string_literal: true

class Section < ApplicationRecord
  include Translatable
  translates :title
  has_many :boxes, inverse_of: :section, dependent: :nullify
  has_many :model_boxes, class_name: 'ModelBox', inverse_of: :section, dependent: :nullify
  positioned

  # TODO: will have to take into account also the other types of content
  # FIXME this does not make much sense
  def content?(locale = I18n.locale)
    boxes.present? and boxes.to_a.count { |b| b.visible? and b.content?(locale) }.positive?
  end
end
