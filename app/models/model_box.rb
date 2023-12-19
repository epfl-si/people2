# frozen_string_literal: true

class ModelBox < ApplicationRecord
  belongs_to :section, class_name: 'Section'
  acts_as_list scope: %i[section_id locale]
end
