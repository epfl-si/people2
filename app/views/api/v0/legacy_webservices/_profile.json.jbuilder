# frozen_string_literal: true

json.sciper     profile.sciper
json.photo_show profile.show_photo? ? 1 : 0
json.photo_url "TODO" if profile.show_photo?
if profile.personal_web_url.present? && profile.show_weburl?
  json.web_perso  profile.personal_web_url
else
  json.web_perso  ""
end
# TODO: after #44
# json.expertise ... this is now a translated rich text box.
