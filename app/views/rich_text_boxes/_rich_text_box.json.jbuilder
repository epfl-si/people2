# frozen_string_literal: true

json.extract! box, :id, :audience, :visibility, :created_at, :updated_at
json.url box_url(box, format: :json)
