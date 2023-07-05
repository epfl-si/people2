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
  def translation_for(attribute, locale=I18n.locale)
    read_attribute("#{attribute}_#{locale}") ||
    read_attribute("#{attribute}_#{I18n.default_locale}")
  end
  def translated_body_for(attribute, locale=I18n.locale)
    puts "tbf attr=#{attribute}, locale=#{locale}"
    puts "self: #{self}"
    t = self.send("#{attribute}_#{locale}")
    puts "t1 = #{t}"
    t = self.send("#{attribute}_#{I18n.default_locale}") if (t.id.nil? || t.body.empty? && locale != I18n.default_locale)
    puts "t2 = #{t}"
    t.body
  end
end