# frozen_string_literal: true

# Idea taken from:
# https://phrase.com/blog/posts/localizing-rails-active-record-models/
module Translatable
  extend ActiveSupport::Concern
  included do
    def self.translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do |locale = I18n.locale|
          translation_for(attribute, locale)
        end
        define_method("t_#{attribute}!") do |locale = I18n.locale|
          translation_for!(attribute, locale)
        end
      end
    end

    def self.inclusively_translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do |gender, locale = I18n.locale|
          inclusive_translation_for(attribute, gender, locale)
        end
      end
    end

    def self.translates_rich_text(*attributes)
      attributes.each do |attribute|
        %w[en fr].each { |l| has_rich_text "#{attribute}_#{l}" }
        define_method("t_#{attribute}") do |locale = I18n.locale|
          translated_body_for(attribute, locale)
        end
      end
    end

    # actual code for translatability validator is in concerns/translatability_validator.rb
    def self.validates_translatability(*attributes); end
  end

  # return translation of a translated attribute in the required locale
  # if available otherwise return the translation in the default locale
  def translation_for(attribute, locale = I18n.locale)
    a = "#{attribute}_#{locale}"
    d = "#{attribute}_#{I18n.default_locale}"
    if respond_to?(a) && respond_to?(d)
      send(a) || send(d)
    else
      instance_variable_get("@#{a}") || instance_variable_get("@#{d}")
    end
  end

  # like the above but nil is returned if translation for locale is not avail.
  def translation_for!(attribute, locale = I18n.locale)
    a = "#{attribute}_#{locale}"
    if respond_to?(a)
      send(a)
    else
      instance_variable_get("@#{a}")
    end
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
      k = "#{attribute}_#{s}"
      res = send(k) || instance_variable_get("@#{k}")
    end
    res
  end
end
