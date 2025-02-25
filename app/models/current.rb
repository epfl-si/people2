# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :primary_lang, :fallback_lang, :gender, :translations
  delegate :user, to: :session, allow_nil: true
end
