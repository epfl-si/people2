# frozen_string_literal: true

class Teachership < ApplicationRecord
  belongs_to :course
  belongs_to :teacher, class_name: "Profile", foreign_key: "profile_id", inverse_of: "teacherships"
end
