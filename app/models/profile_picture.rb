class ProfilePicture < ApplicationRecord
  belongs_to :cv
  has_one_attached :image

  def sciper
    cv.id
  end
end
