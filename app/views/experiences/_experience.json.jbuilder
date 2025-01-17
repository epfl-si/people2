# frozen_string_literal: true

json.extract! experience, :id, :title_en, :title_fr, :location, :year_begin, :year_end, :position, :created_at,
              :updated_at, :position, :audience, :visibility
json.profile profile_url(experience.profile, format: :json)
json.url experience_url(experience, format: :json)
