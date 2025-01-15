# frozen_string_literal: true

json.extract! publication, :id, :title, :url, :authors, :year,
              :audience, :visibility, :created_at, :position, :updated_at
json.profile profile_url(publication.profile, format: :json)
json.url publication_url(publication, format: :json)
