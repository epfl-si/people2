# frozen_string_literal: true

class Box < ApplicationRecord
  include AudienceLimitable
  include Translatable
  serialize  :data, coder: YAML
  belongs_to :section, class_name: 'Section'
  belongs_to :profile, class_name: 'Profile'
  belongs_to :model, class_name: "ModelBox", foreign_key: "model_box_id", inverse_of: :boxes
  scope :index_type, -> { where(type: IndexBox) }
  scope :text_type, -> { where(type: RichTextBox) }

  # before_create :ensure_sciper
  positioned on: %i[profile section locked]

  translates :title

  def self.from_model(mb)
    new(
      section: mb.section,
      model: mb,
      subkind: mb.subkind,
      title_en: mb.title_en,
      title_fr: mb.title_fr,
      show_title: mb.show_title,
      locked: true,
      position: mb.position,
      data: mb.data
    )
  end

  # TODO: implement this
  def content?(_locale = I18n.default_locale)
    true
  end

  delegate :sciper, to: :profile
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
