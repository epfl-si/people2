# frozen_string_literal: true

class Box < ApplicationRecord
  include AudienceLimitable
  include Translatable
  audience_limit
  translates :title
  serialize  :data, coder: YAML
  belongs_to :section, class_name: 'Section'
  belongs_to :profile, class_name: 'Profile'
  belongs_to :model, class_name: "ModelBox", foreign_key: "model_box_id", inverse_of: :boxes
  scope :index_type, -> { where(type: IndexBox) }
  scope :text_type, -> { where(type: RichTextBox) }
  scope :in_section, ->(section) { where(section: section) }
  validates :t_title, translatability: true

  # before_create :ensure_sciper
  positioned on: %i[profile section]

  def self.from_model(mb, params = {})
    klass = Object.const_get(mb.kind)
    b = klass.new
    mbparams = {
      section: mb.section,
      model: mb,
      type: mb.kind,
      subkind: mb.subkind,
      title_en: mb.title_en,
      title_fr: mb.title_fr,
      title_it: mb.title_it,
      title_de: mb.title_de,
      show_title: mb.show_title,
      locked_title: mb.locked_title,
      position: mb.position,
      data: mb.data
    }
    b.assign_attributes(mbparams.merge(params))
    b
  end

  # primary_locale = nil, fallback_locale = nil

  # TODO: may be this should be a property stored in the DB and copied from mb upon initialization
  def container?
    type == "IndexBox"
  end

  def content?(_primary_locale = nil, _fallback_locale = nil)
    raise "The (abstract) 'content?' method needs to be implemented in the class"
  end

  def content_for?(audience_level = 0, _primary_locale = nil, _fallback_locale = nil)
    visible_by?(audience_level)
  end

  # Sync with model_box
  def sync!
    return if model_box_id.nil?

    mb = model
    if mb.locked_title
      self.title_en = mb.title_en
      self.title_fr = mb.title_fr
      self.title_it = mb.title_it
      self.title_de = mb.title_de
    end
    self.show_title = mb.show_title
    self.locked_title = mb.locked_title
    save!
  end

  def user_destroyable?
    !standard?
  end

  delegate :sciper, to: :profile
  delegate :standard?, to: :model
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
