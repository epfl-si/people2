# frozen_string_literal: true

class ModelBox < ApplicationRecord
  belongs_to :section, class_name: 'Section'
  has_many :boxes, class_name: "Box", dependent: :nullify
  positioned on: %i[section_id locale]
  serialize  :data, coder: YAML

  def new_box_for_profile(profile)
    box = Object.const_get(kind).send("from_model", self)
    box.profile = profile
    box
  end
end
