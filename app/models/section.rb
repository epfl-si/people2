class Section < ApplicationRecord
  include Translatable
  translates :title
	has_many :boxs, :class_name => "Box"
	has_many :model_boxes, :class_name => "ModelBox"
	acts_as_list
end

class ModelBox < ApplicationRecord
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  acts_as_list scope: [:section_id, :locale]
end
