class Box < ApplicationRecord
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  belongs_to :cv, :class_name => "Cv", :foreign_key => "cv_id"
  acts_as_list scope: [:cv, :section, :frozen]

  translates :title

  def self.from_model(mb)
    self.new(
      section_id: mb.section_id,
      kind: "model",
      title_en: mb.title_en,
      title_fr: mb.title_fr,
      show_title: mb.show_title,
      frozen: true,
      position: mb.position
    )
  end
end

class TextBox < Box
  translates :content
  has_rich_text :content_en
  has_rich_text :content_fr
end

# class AchievementsBox < Box
#   has_many :achievements
# end

# class AwardsBox < Box
#   has_many :awards
# end

# class EducationBox < Box
#   has_many :educations
# end
