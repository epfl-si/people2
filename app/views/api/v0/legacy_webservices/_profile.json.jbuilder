# frozen_string_literal: true

json.sciper profile.sciper
json.photo_visiblity profile.photo_visiblity
json.photo_url "TODO" if profile.photo_visible_by?(@audience)
if profile.personal_web_url.present? && profile.personal_web_url_visible_by?(@audience)
  json.web_perso  profile.personal_web_url
else
  json.web_perso  ""
end
# TODO: after #44
# json.expertise ... this is now a translated rich text box.
