# frozen_string_literal: true

json.sciper profile.sciper.to_i
json.photo_visibility profile.photo_visibility || ""
json.titre "" # Customizable title no longer possible NM dixit
img = profile&.photo&.visible_image
if profile.photo_public? && img.present?
  # json.photo_url url_for(img.variant(:medium2))
  json.photo_show 1
  json.photo_url rails_representation_url(img.variant(:medium2))
else
  json.photo_show 0
  json.photo_url image_url('profile_image_placeholder.svg')
end
if profile.personal_web_url.present? && profile.personal_web_url_public?
  json.web_perso profile.personal_web_url || ""
else
  json.web_perso ""
end
# # TODO: after #44
# # json.expertise ... this is now a translated rich text box.
