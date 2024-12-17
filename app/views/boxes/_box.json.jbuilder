# frozen_string_literal: true

json.extract! box, :id, :type, :subkind, :title_en, :title_fr, :show_title, :locked,
              :updated_at, :position, :audience, :visible
json.profile profile_url(box.profile, format: :json)
