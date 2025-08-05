# frozen_string_literal: true

# Profile is the former _common_ table where we store most of the simple
# editable user's data.
# The read-only official data comes from external sources like
# accred & co. via api.epfl.ch and ISAcademia.

class Profile < ApplicationRecord
  # predefined primary key will brake testing when labels are used in fixtures
  # therefore, although I would much prefer to have sciper as the primary key,
  # I decided to abandon the idea in favor of ehnanced fixture readability.
  # I will probably duplicate sciper value in all models where it can be useful.
  # https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html
  # self.primary_key = 'sciper'
  EXPERTISE_MAX_LEN = 200

  include AudienceLimitable
  include Translatable
  translates :nationality, :title, :expertise
  audience_limit_property "birthday"
  audience_limit_property "expertise"
  audience_limit_property "nationality"
  audience_limit_property "phone"
  audience_limit_property "photo"
  audience_limit_property "personal_phone"
  audience_limit_property "personal_web_url"

  validates :personal_web_url, format: { with: %r{\A(http|https)://[^\s]+\z}, message: :invalid_url, allow_blank: true }
  validates :personal_phone, format: { with: /\A(\+|00)?[0-9\s\-.()]+\z/, message: :invalid_phone, allow_blank: true }
  has_many :boxes, dependent: :destroy
  has_many :model_boxes, through: :boxes, source: :model
  # has_many :section_boxes, ->(section) { where(section_id: section.id) }, class_name: 'Box'
  has_many :index_boxes, class_name: 'IndexBox', dependent: :destroy
  has_many :text_boxes, class_name: 'RichTextBox', dependent: :destroy
  has_many :socials, dependent: :destroy
  has_many :achievements, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :infosciences, dependent: :destroy
  has_many :publications, dependent: :destroy
  has_many :usual_name_changes, dependent: :destroy
  has_many :usual_name_requests, dependent: :destroy

  accepts_nested_attributes_for :boxes, :socials, :awards, :educations, :experiences

  # TIP: avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :pictures, class_name: 'Picture', dependent: :destroy
  belongs_to :selected_picture, class_name: 'Picture',
                                optional: true, inverse_of: false
  belongs_to :camipro_picture, class_name: 'Picture',
                               optional: true, inverse_of: false

  has_many :accreds, class_name: 'Accred', dependent: :destroy
  # TODO: switch to new model

  # has_and_belongs_to_many :courses, join_table: "teacherships"
  has_many :teacherships, class_name: "Teachership", dependent: :destroy
  has_many :courses, through: :teacherships

  # TODO: add all presence validations. Translated properties should be present
  #       in at leat one of the languages when property is visible
  validates :sciper, uniqueness: true

  validates :expertise_en, length: { maximum: EXPERTISE_MAX_LEN }
  validates :expertise_fr, length: { maximum: EXPERTISE_MAX_LEN }
  validates :expertise_it, length: { maximum: EXPERTISE_MAX_LEN }
  validates :expertise_de, length: { maximum: EXPERTISE_MAX_LEN }

  # We have to call complete_standard_boxes! upon each edit anyway
  # after_create :create_standard_boxes
  after_create :cache_camipro_picture!

  DEFAULTS = {
    birthday_visibility: AudienceLimitable::HIDDEN,
    expertise_visibility: AudienceLimitable::VISIBLE,
    nationality_visibility: AudienceLimitable::HIDDEN,
    phone_visibility: AudienceLimitable::VISIBLE,
    photo_visibility: AudienceLimitable::HIDDEN,
    personal_phone_visibility: AudienceLimitable::HIDDEN,
    personal_web_url_visibility: AudienceLimitable::HIDDEN,
    personal_phone: nil,
    personal_web_url: nil,
    expertise_en: nil,
    expertise_fr: nil,
    expertise_it: nil,
    expertise_de: nil,
    nationality_en: nil,
    nationality_fr: nil,
    nationality_it: nil,
    nationality_de: nil,
  }.freeze

  def self.new_with_defaults(sciper)
    new(DEFAULTS.merge(sciper: sciper))
  end

  def self.create_with_defaults(sciper)
    create(DEFAULTS.merge(sciper: sciper))
  end

  def self.for_sciper(sciper)
    # returns nil when nothing found
    where(sciper: sciper).first
  end

  delegate :doctoral?, :gender, :name, :staff?, :student?, :email, :public_email, to: :person

  # I have tried to put all these flags into a single
  def translations
    [
      [:en, en_enabled], [:fr, fr_enabled],
      [:it, it_enabled], [:de, de_enabled]
    ].to_h.select { |_k, v| v }.keys
  end

  def fallback_translation
    translations.first || "fr"
  end

  def person
    @person ||= Person.find(sciper)
  end

  def photo(audience = 0)
    photo_visible_by?(audience) ? photo! : nil
  end

  def photo!
    if selected_picture.present?
      selected_picture
    elsif camipro_picture.present?
      camipro_picture
    else
      cache_camipro_picture!
    end
  end

  # def camipro_picture
  #   pictures.camipro.first
  # end

  def any_publication?
    publications.present?
  end

  # TODO: this whole idea of enforcing boxes everywhere is not great. Here we
  # will end up filling the DB with empty box records just to make the views
  # reasonably simple. Also, if we decide to change the title of a model box
  # the change will not be propagated automatically to existing records.
  # I think we should introduce two type different tables in the DB
  #  1. like now but only for optional / user-added boxes;
  #  2. a join table linking Profile and ModelBox that we also use for storing
  #     visibility informations.
  # Still to figure out how we manage the box type. Will we duplicate what we
  # now have for the models derived from Box ?
  # def create_standard_boxes
  #   ModelBox.all.includes(:section).each do |mb|
  #     mb.new_box_for_profile(self).save!
  #   end
  # end

  def available_optional_boxes(section = nil)
    @box_count_by_model ||= boxes.group(:model_box_id).count
    if section.present?
      section.model_boxes.optional
    else
      ModelBox.includes(:section).optional
    end.select { |b| (@box_count_by_model[b.id] || 0) < b.max_copies }
  end

  # Check that all standard (ModelBox) boxes are present for this profile
  def complete_standard_boxes!
    model_box_ids = boxes.map(&:model_box_id).uniq.compact
    ModelBox.standard.where.not(id: model_box_ids).includes(:section).find_each do |mb|
      b = mb.new_box_for_profile(self)
      b.save!
      boxes << b
    end
  end

  def cache_camipro_picture!
    return if camipro_picture_id.present?

    cpp = pictures.create!(source: "camipro")
    cpp.fetch
    self.camipro_picture_id = cpp.id
    self.selected_picture_id ||= cpp.id
    save!
    cpp
  end
end
