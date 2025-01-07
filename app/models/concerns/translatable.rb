# frozen_string_literal: true

# Idea taken from:
# https://phrase.com/blog/posts/localizing-rails-active-record-models/
#
# Including this module, will define the following class methods:
#  * translates(list of attribute names)
#    when called will define the following instance methods foreach given attribute
#    - t_attrname (e.g. `t_title`)
#      return the content in the most appropriate language (given -> primary -> fallback)
#    - t_attrname! (e.g. `t_title!('en')` or `t_title!()`)
#      return the content in the explicitly provided language or in the current primary_language
#  * translates_rich_text(list of attribute names)
#    essentially as the above but for rich text boxes
#    when called will define the following instance method foreach given attribute
#    - t_attrname (e.g. `t_title`)
#      return the content in the most appropriate language (given -> primary -> fallback)
#  * inclusively_translates(list of attribute names)
#    as above but in this case, the attribute will be also declined by gender
#    when called will define the following instance method foreach given attribute:
#    - t_attrname (e.g. `t_job('m', 'fr')` or `t_job()`)

module Translatable
  extend ActiveSupport::Concern
  included do
    def self.translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do |primary_locale = nil, fallback_locale = nil|
          translation_for(attribute, primary_locale, fallback_locale)
        end
        define_method("t_#{attribute}!") do |locale = nil|
          translation_for!(attribute, locale)
        end
      end
    end

    def self.inclusively_translates(*attributes)
      attributes.each do |attribute|
        define_method("t_#{attribute}") do |gender = nil, primary_locale = nil, fallback_locale = nil|
          inclusive_translation_for(attribute, gender, primary_locale, fallback_locale)
        end
      end
    end

    def self.translates_rich_text(*attributes)
      attributes.each do |attribute|
        Rails.configuration.available_languages.each { |l| has_rich_text "#{attribute}_#{l}" }
        define_method("t_#{attribute}") do |primary_locale = nil, fallback_locale = nil|
          translated_body_for(attribute, primary_locale, fallback_locale)
        end
      end
    end

    # actual code for translatability validator is in concerns/translatability_validator.rb
    def self.validates_translatability(*attributes); end
  end

  # return translation of a translated attribute in the required locale
  # if available otherwise return the translation in the default locale
  def translation_for(attribute, primary_lang = nil, fallback_lang = nil)
    primary_lang ||= Thread.current[:primary_lang] || I18n.locale
    fallback_lang ||= Thread.current[:fallback_lang] || I18n.default_locale

    a = "#{attribute}_#{primary_lang}"
    d = "#{attribute}_#{fallback_lang}"
    if respond_to?(a) && respond_to?(d)
      send(a) || send(d)
    else
      instance_variable_get("@#{a}") || instance_variable_get("@#{d}")
    end
  end

  # like the above but nil is returned if translation for locale is not avail.
  def translation_for!(attribute, lang = Thread.current[:primary_lang])
    raise "translation_for! needs lang to be defined!" if lang.nil?

    a = "#{attribute}_#{lang}"
    if respond_to?(a)
      send(a)
    else
      instance_variable_get("@#{a}")
    end
  end

  def translated_body_for(attribute, primary_lang = nil, fallback_lang = nil)
    primary_lang ||= Thread.current[:primary_lang] || I18n.locale
    fallback_lang ||= Thread.current[:fallback_lang] || I18n.default_locale

    t = send("#{attribute}_#{primary_lang}")
    t = send("#{attribute}_#{fallback_lang}") if primary_lang != fallback_lang && (t.id.nil? || t.body.empty?)
    t.id.nil? || t.body.empty? ? nil : t.body
  end

  def inclusive_translation_for(attribute, gender = nil, primary_lang = nil, fallback_lang = nil)
    gender ||= Thread.current[:gender]
    if gender.nil?
      raise "inclusive_translation_for requires gender to be passed explicitly or set as Thread.current[:gender]"
    end

    primary_lang ||= Thread.current[:primary_lang] || I18n.locale
    fallback_lang ||= Thread.current[:fallback_lang] || I18n.default_locale
    inclusive_translation_for!(attribute, gender,
                               primary_lang) || inclusive_translation_for!(attribute, gender, fallback_lang)
  end

  def inclusive_translation_for!(attribute, gender, locale)
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
