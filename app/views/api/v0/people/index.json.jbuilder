# frozen_string_literal: true

if @structure.present?
  json.partial! 'people_struct', people: @people, structure: @structure
else
  json.partial! 'people_alpha', people: @people
end
