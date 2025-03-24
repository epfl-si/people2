# frozen_string_literal: true

json.extract! infoscience, :id, :title_en, :title_fr, :title_it, :title_de,
              :updated_at, :position, :visibility

json.profile profile_url(infoscience.profile, format: :json)
json.url infoscience_url(infoscience, format: :json)
