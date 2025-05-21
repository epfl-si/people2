# frozen_string_literal: true

require "cld"

# This contains various text that require AI translation and/or language detection
# for language detection we first try with https://github.com/jtoy/cld because
# it offers a reliability measure.
# It is our precomputed dictionary.
module Work
  class Text < Work::Base
    include ActionView::Helpers::SanitizeHelper
    before_validation :ensure_signature
    validates :signature, presence: true

    has_many :ai_translations, class_name: 'AiTranslation', dependent: :destroy

    scope :wotrans, -> { where.missing(:ai_translations) }

    # Return the object with the given content
    def self.for(text)
      k = Digest::MD5.hexdigest(text)
      where(signature: k).includes(:ai_translations).first
    end

    # If not present, the object with given content is created. This way we
    # collect a list of untranslated models that we can send to the AI in blocks
    def self.for!(text)
      self.for(text) || new(content: text)
    end

    def lang
      cld_lang || ai_lang
    end

    def translated(locale)
      return content if lang.present? && locale.to_s == lang

      ai_translations.where.not("content_#{locale}": nil).sort(&:confidence).first&.send("content_#{locale}")
    end

    def cld_lang
      cld[:reliable] ? cld[:code] : nil
    end

    def ai_lang
      ai_translations.sort(&:confidence).first&.lang
    end

    def text_content
      @text_content ||= strip_tags(content)
    end

    private

    def cld
      @cld ||= CLD.detect_language(text_content)
    end

    def ensure_signature
      return if signature.present?

      self.signature = Digest::MD5.hexdigest(content)
    end
  end
end
