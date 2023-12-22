# frozen_string_literal: true

class RichTextBox < Box
  translates_rich_text :content

  def content?(locale = I18n.default_locale)
    super(locale) && send("content_#{locale}?")
  end
end
