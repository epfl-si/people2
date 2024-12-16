# frozen_string_literal: true

json.extract! education, :id, :field_en, :field_fr, :title_en, :title_fr,
              :year_begin, :year_end, :school, :director,
              :created_at, :updated_at
json.profile profile_url(education.profile, format: :json)
json.url education_url(education, format: :json)
