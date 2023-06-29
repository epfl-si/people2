module CvHelper
	def profile_picture(cv=nil)
		opts={alt: "Avatar image", class: "img-fluid bg-gray-100"}
		if cv.present? and cv.show_photo
			if cv.profile_picture.present?
				image_tag(cv.profile_picture.image.representation(resize_to_limit: [400, 400]), opts)
				# image_tag(cv.profile_picture.image, opts)
			else
				image_tag(cv.camipro_photo_url, opts)
			end
		else
			image_tag(belurl 'svg/portrait-placeholder.svg', otps)
		end
	end
end
