class Cv < ApplicationRecord
  include Translatable
  translates :nationality

  has_many :boxes,  :class_name => "Box"

  def sciper
    self.id
  end

  def sciper=(v)
    self.id=(v.to_i)
  end

  def init_boxes!
    return unless self.boxes.empty?
    ModelBox.all.each do |mb|
      b = Box.from_model(mb)
      b.cv = self
      b.save
    end
  end

end
