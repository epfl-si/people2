# frozen_string_literal: true

module CvHelper
  def profile_picture(profile = nil, audience = 0)
    opts = { alt: 'Avatar image', class: 'mx-auto img-fluid bg-gray-100' }
    if profile.present? && profile.photo_visible_by?(audience)
      p = profile.photo(audience)
      if p.image.attached?
        image_tag(p.image.representation(resize_to_limit: [400, 400]), opts)
      else
        image_tag(belurl('svg/portrait-placeholder.svg'), opts)
      end
    else
      image_tag(belurl('svg/portrait-placeholder.svg'), opts)
    end
  end
end
