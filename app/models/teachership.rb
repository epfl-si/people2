# frozen_string_literal: true

class Teachership < ApplicationRecord
  belongs_to :course
  # Although all teachers have a profile, it actually does not make much sense
  # to link courses to profile instead of person. This will permit to have
  # correct pages for teachers that do not bother filling in their profile
  # belongs_to :teacher, class_name: "Profile", foreign_key: "profile_id", inverse_of: "teacherships"
end
