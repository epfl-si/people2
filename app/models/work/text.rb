# frozen_string_literal: true

require "cld"

# This contains various text that require AI translation and/or language detection
# for language detection we first try with https://github.com/jtoy/cld
module Work
  class Text < Work::Base
    include ActionView::Helpers::SanitizeHelper

    has_many :ai_translations, class_name: 'AiTranslation', dependent: :destroy

    scope :wotrans, -> { where.missing(:ai_translations) }

    def lang
      cld[:reliable] ? cld[:code] : nil
    end

    def text_content
      @text_content ||= strip_tags(content)
    end

    private

    def cld
      @cld ||= CLD.detect_language(text_content)
    end
  end
end
