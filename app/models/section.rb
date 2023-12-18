class Section < ApplicationRecord
  include Translatable
  translates :title
  has_many :boxes
  has_many :model_boxes, class_name: "ModelBox"
  acts_as_list

  # TODO: will have to take into account also the other types of content
  # FIXME this does not make much sense
  def have_content?(locale = I18n.locale)
    boxes.present? and boxes.to_a.count { |b| b.visible? and b.have_content?(locale) } > 0
  end
end
