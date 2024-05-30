# frozen_string_literal: true

json.extract! award, :id, :title_en, :title_fr, :issuer, :year, :created_at,
              :updated_at, :position, :audience, :visible
json.profile profile_url(award.profile, format: :json)
json.url award_url(award, format: :json)
