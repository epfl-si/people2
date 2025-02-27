# frozen_string_literal: true

@awards.each do |a|
  json.child! do
    json.id       a.id
    json.sciper   a.sciper
    json.year     a.year
    json.category a.category.t_name
    json.origin   a.origin.t_name
    json.title    a.t_title
    json.issuer   a.issuer
    json.url      a.url
  end
end
