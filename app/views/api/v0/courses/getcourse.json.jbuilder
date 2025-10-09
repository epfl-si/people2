# frozen_string_literal: true

json.array! @courses do |c|
  json.X_MATIERE       c.t_title
  json.C_LANGUEENS     c.lang
  json.X_URL           c.verified_edu_url!(@locale) || ''
  json.X_OBJECTIFS     c.t_description
end
