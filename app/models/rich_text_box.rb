class RichTextBox < Box
  has_translated_rich_text :content

  def have_content?(locale=I18n.default_locale)
    super(locale) && translated_body_for(:content, locale).present?
  end
end