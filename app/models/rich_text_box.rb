# frozen_string_literal: true

class RichTextBox < Box
  translates_rich_text :content
  # Not sure: it might inhibit the creation of
  # validates :t_content, translatability: true

  def content?(primary_locale = nil, fallback_locale = nil)
    t_content(primary_locale, fallback_locale).present?
  end

  def content_for?(audience_level = 0, primary_locale = nil, fallback_locale = nil)
    visible_by?(audience_level) && content?(primary_locale, fallback_locale)
  end
end
