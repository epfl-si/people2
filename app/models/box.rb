class Box < ApplicationRecord
  include Translatable
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  belongs_to :cv, :class_name => "Cv", :foreign_key => "cv_id"
  # before_create :ensure_sciper
  scope :visible, -> { where(visible: true) }
  acts_as_list scope: [:cv, :section, :frozen]

  translates :title

  def self.from_model(mb)
    self.new(
      section_id: mb.section_id,
      title_en: mb.title_en,
      title_fr: mb.title_fr,
      show_title: mb.show_title,
      frozen: true,
      position: mb.position
    )
  end

  def have_content?(locale=I18n.default_locale)
    true
  end

  def sciper
    cv.sciper
  end

 private
  # def ensure_sciper
  #   self.sciper ||= self.cv.sciper
  # end
end

# Subclasses in STI need to be on their own file because otherwise 
# autoreload in dev does not work

# class RichTextBox < Box
# end

# class AchievementsBox < Box
#   has_many :achievements
# end

# class AwardsBox < Box
#   has_many :awards
# end

# class EducationBox < Box
#   has_many :educations
# end

# https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html
# https://medium.com/@GeneHFang/single-table-inheritance-in-rails-6-emulating-oop-principles-in-relational-databases-be60c84e0126
# https://juzer-shakir.medium.com/single-table-inheritance-sti-769070972ea2