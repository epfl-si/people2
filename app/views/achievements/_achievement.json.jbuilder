# frozen_string_literal: true

json.extract! award, :id, :description_en, :description_fr, :url, :year,
              :updated_at, :position, :visibility

json.profile profile_url(award.profile, format: :json)
json.url award_url(award, format: :json)
