# frozen_string_literal: true

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

    def self.translated_rich_text(*attributes)
      attributes.each do |attribute|
        %w[en fr].each { |l| has_rich_text "#{attribute}_#{l}" }
        define_method("#{attribute}_body") do
          translated_body_for(attribute)
        end
      end
    end
  end
  def translation_for(attribute, locale = I18n.locale)
    self["#{attribute}_#{locale}"] ||
      self["#{attribute}_#{I18n.default_locale}"]
  end

  def translated_body_for(attribute, locale = I18n.locale)
    Rails.logger.debug "tbf attr=#{attribute}, locale=#{locale}"
    Rails.logger.debug "self: #{self}"
    t = send("#{attribute}_#{locale}")
    Rails.logger.debug "t1 = #{t}"
    t = send("#{attribute}_#{I18n.default_locale}") if t.id.nil? || t.body.empty? && locale != I18n.default_locale
    Rails.logger.debug "t2 = #{t}"
    t.body
  end
end
