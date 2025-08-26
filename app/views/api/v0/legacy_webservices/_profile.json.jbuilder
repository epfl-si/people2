# frozen_string_literal: true

json.sciper profile.sciper
json.photo_visibility profile.photo_visibility
json.photo_url rails_representation_url(profile.photo.image.variant(:medium).processed) if profile.photo_public?
if profile.personal_web_url.present? && profile.personal_web_url_public?
  json.web_perso profile.personal_web_url
else
  json.web_perso ""
end
# # TODO: after #44
# # json.expertise ... this is now a translated rich text box.
