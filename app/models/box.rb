class Box < ApplicationRecord
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  belongs_to :cv, :class_name => "Cv", :foreign_key => "cv_id"
  acts_as_list scope: [:cv, :section, :locale, :frozen]

  has_rich_text :content

  def self.from_model(mb)
    self.new(
      section_id: mb.section_id,
      kind: mb.label, 
      locale: mb.locale,
      title: mb.title,
      show_title: mb.show_title,
      frozen: true,
      position: mb.position
    )
  end
end
