class Box < ApplicationRecord
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  belongs_to :cv, :class_name => "Cv", :foreign_key => "cv_id"
  acts_as_list scope: [:cv, :section, :locale]
end
