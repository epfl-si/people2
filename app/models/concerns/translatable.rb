# frozen_string_literal: true

# Idea taken from:
# https://phrase.com/blog/posts/localizing-rails-active-record-models/
module Translatable
  extend ActiveSupport::Concern
  included do
    def self.translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do
          translation_for(attribute)
        end
      end
    end

    def self.inclusively_translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do |gender = 'X'|
          inclusive_translation_for(attribute, gender)
        end
      end
    end

    def self.translates_rich_text(*attributes)
      attributes.each do |attribute|
        %w[en fr].each { |l| has_rich_text "#{attribute}_#{l}" }
        define_method("t_#{attribute}") do
          translated_body_for(attribute)
        end
      end
    end
  end

  def translation_for(attribute, locale = I18n.locale)
    send("#{attribute}_#{locale}") ||
      send("#{attribute}_#{I18n.default_locale}")
  end

  def translated_body_for(attribute, locale = I18n.locale)
    t = send("#{attribute}_#{locale}")
    t = send("#{attribute}_#{I18n.default_locale}") if t.id.nil? || t.body.empty? && locale != I18n.default_locale
    t.body
  end

  def inclusive_translation_for(attribute, gender, locale = I18n.locale)
    # Not all genderized columns are always available.
    # Therefore we try to chose a reasonable fallback.
    suffixes = case locale
               when :en, 'en'
                 ['en']
               when :fr, 'fr'
                 case gender
                 when 'M'
                   ['frm']
                 when 'X'
                   %w[fri frm frf]
                 when 'F'
                   %w[frf fri frm]
                 else
                   %w[fri frm frf]
                 end
               else
                 ['en']
               end
    res = nil
    while (s = suffixes.shift) && res.nil?
      res = send("#{attribute}_#{s}")
    end
    res
  end
end
