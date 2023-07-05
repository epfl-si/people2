class Box < ApplicationRecord
  include Translatable
  belongs_to :section, :class_name => "Section", :foreign_key => "section_id"
  belongs_to :cv, :class_name => "Cv", :foreign_key => "cv_id"
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
end

class RichTextBox < Box
  has_translated_rich_text :content

  def have_content?(locale=I18n.default_locale)
    # puts "TextBox::have_content? locale=#{locale}"
    super(locale) && translated_body_for(:content, locale).present?
  end
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

# https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html
# https://medium.com/@GeneHFang/single-table-inheritance-in-rails-6-emulating-oop-principles-in-relational-databases-be60c84e0126
# https://juzer-shakir.medium.com/single-table-inheritance-sti-769070972ea2