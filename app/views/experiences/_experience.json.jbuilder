# frozen_string_literal: true

json.extract! experience, :id, :created_at, :updated_at
json.url experience_url(experience, format: :json)
