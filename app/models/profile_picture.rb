# frozen_string_literal: true

class ProfilePicture < ApplicationRecord
  belongs_to :profile
  has_one_attached :image

  def sciper
    cv.id
  end
end
