# Idea taken from:
# https://phrase.com/blog/posts/localizing-rails-active-record-models/
module Translatable
  extend ActiveSupport::Concern
  included do
    def self.translates(*attributes)
      attributes.each do |attribute|
        define_method(attribute) do
          translation_for(attribute)
        end
      end
    end
    def self.has_translated_rich_text(*attributes)
      attributes.each do |attribute|
        ["en", "fr"].each {|l| has_rich_text "#{attribute}_#{l}"} 
        define_method("#{attribute}_body") do
          translated_body_for(attribute)
        end
      end      
    end
  end
  def translation_for(attribute)
    read_attribute("#{attribute}_#{I18n.locale}") ||
    read_attribute("#{attribute}_#{I18n.default_locale}")
  end
  def translated_body_for(attribute)
    locales = [I18n.locale, I18n.default_locale].uniq
    t = send("#{attribute}_#{I18n.locale}")
    t = send("#{attribute}_#{I18n.default_locale}") if (t.id.nil? || t.body.empty?) && I18n.locale != I18n.default_locale
    t.body
  end
end