# frozen_string_literal: true

json.extract! social, :id, :tag, :value,
              :audience, :created_at, :position, :updated_at
json.profile profile_url(social.profile, format: :json)
json.url social_url(social, format: :json)
