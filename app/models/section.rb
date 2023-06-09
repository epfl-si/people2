class Section < ApplicationRecord
  include Translatable
  translates :title
	has_many :boxes, :class_name => "Box", :foreign_key => "section_id"
	has_many :model_boxes, :class_name => "ModelBox"
	acts_as_list
end
