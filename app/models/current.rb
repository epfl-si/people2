# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :primary_lang, :fallback_lang, :gender,
            :translations, :audience, :original_audience,
            :request_default_locale, :available_locales
  delegate :user, to: :session, allow_nil: true
end
