# frozen_string_literal: true

class ModelBox < ApplicationRecord
  belongs_to :section, class_name: 'Section'
  positioned on: %i[section_id locale]
end
