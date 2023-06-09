class Cv < ApplicationRecord
  include Translatable
  translates :nationality, :title

  has_many :boxes,  :class_name => "Box"

  def sciper
    self.id
  end

  def sciper=(v)
    self.id=(v.to_i)
  end

  # create an instance of each standard box for a new person. Most might
  # remain empty but it simplifies a lot. This will be executed only
  # the first time the user tries to edit his profile
  def init_boxes!
    return unless self.boxes.empty?
    ModelBox.all.each do |mb|
      b = Box.from_model(mb)
      b.cv = self
      b.save
    end
  end

end
