# frozen_string_literal: true

json.extract! admin_translation, :id, :file, :en, :fr, :it, :de, :done, :created_at, :updated_at
json.url admin_translation_url(admin_translation, format: :json)
