# frozen_string_literal: true

module CvHelper
  def profile_picture(cv = nil)
    opts = { alt: 'Avatar image', class: 'img-fluid bg-gray-100' }
    if cv.present? && cv.show_photo
      p = cv.selected_picture
      if p.present?
        image_tag(p.image.representation(resize_to_limit: [400, 400]), opts)
        # image_tag(cv.profile_picture.image, opts)
      else
        image_tag(cv.photo_url, opts)
      end
    else
      image_tag(belurl('svg/portrait-placeholder.svg'), opts)
    end
  end
end
