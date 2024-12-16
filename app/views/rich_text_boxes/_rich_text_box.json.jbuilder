# frozen_string_literal: true

json.extract! box, :id, :created_at, :updated_at
json.url box_url(box, format: :json)
