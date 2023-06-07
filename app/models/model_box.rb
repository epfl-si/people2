class ModelBox < ApplicationRecord
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  acts_as_list scope: [:section_id, :locale]
end
