class Section < ApplicationRecord
  include Translatable
  translates :title
	has_many :boxs, :class_name => "Box"
	has_many :model_boxes, :class_name => "ModelBox"
	acts_as_list
end
