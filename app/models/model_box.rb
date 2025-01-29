# frozen_string_literal: true

class ModelBox < ApplicationRecord
  include Translatable
  translates :title, :description
  belongs_to :section, class_name: 'Section'
  has_many :boxes, class_name: "Box", dependent: :nullify
  positioned on: %i[section_id locale]
  serialize  :data, coder: YAML
  validates :label, uniqueness: true
  validates :title_en, presence: true, if: -> { locked_title? }
  validates :title_fr, presence: true, if: -> { locked_title? }
  validates :title_it, presence: true, if: -> { locked_title? }
  validates :title_de, presence: true, if: -> { locked_title? }

  scope :standard, -> { where(standard: true) }
  scope :optional, -> { where(standard: false) }

  def self.for_label(label)
    where(label: label).first
  end

  def container?
    kind == "IndexBox"
  end

  def new_box_for_profile(profile)
    box = Object.const_get(kind).send("from_model", self)
    box.profile = profile
    box
  end
end
