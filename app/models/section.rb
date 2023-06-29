class Section < ApplicationRecord
  include Translatable
  translates :title
	has_many :boxes, :class_name => "Box", :foreign_key => "section_id"
	has_many :model_boxes, :class_name => "ModelBox"
	acts_as_list

	# TODO will have to take into account also the other types of content
	def have_content?
		self.boxes.present? and self.boxes.to_a.count{|b| b.visible? and b.content?}>0
	end
end
