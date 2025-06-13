# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :primary_lang, :fallback_lang, :gender, :translations, :audience, :original_audience
  delegate :user, to: :session, allow_nil: true
end
