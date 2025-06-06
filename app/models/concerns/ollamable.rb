# frozen_string_literal: true

module Ollamable
  extend ActiveSupport::Concern

  LANGS = {
    en: "english",
    fr: "french",
    it: "italian",
    de: "german"
  }.freeze
  LANG_CODES = LANGS.keys.map(&:to_s).freeze
  AIMODEL = 'llama3.2'
  CONFIDENCE = 0.2

  included do
    def self.ollamizes(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}_lang?") do
          text = send(attribute)
          ollama_detect_language(text)
        end
        # TODO: check that we are not translating to the same language
        define_method("tr_#{attribute}") do |locale = :fr|
          text = send(attribute)
          ollama_translate(text, LANGS[locale])
        end
        define_method("trh_#{attribute}") do |locale = :fr|
          text = send(attribute)
          ollama_translate_with_html(text, LANGS[locale])
        end
      end
    end
  end

  def ollama_query(prompt)
    begin
      url = Rails.application.config_for(:ollama).url
      @ollama ||= Ollama.new(
        credentials: { address: url },
        options: { server_sent_events: true }
      )
      result = @ollama.generate({
                                  model: AIMODEL,
                                  prompt: prompt,
                                  stream: false
                                })
    rescue StandardError
      Rails.logger.warn "Could not connect to Ollama server."
      return nil
    end
    result = result&.first
    return nil if result.blank?

    result["response"]
  end

  # TODO: ask to give a confidence level and return nil if below a give threshold
  def ollama_detect_language(text)
    t = Work::Text.for!(text)
    return t.lang.to_sym unless t.lang.nil?

    # No cached language detection available yet.

    q = "
      can you tell if the following text is in english
      or french (no need to provide explaination, just the language) ?
    "
    r = ollama_query("#{q}: #{text}")
    l = case r
        when /fr/i
          :fr
        when /^en|eng/i
          :en
        when /it/i
          :it
        when /ge/i
          :de
        end
    # Save this request for future usage
    t.ai_translations.create(
      ai_model: "ollama/#{AIMODEL}",
      lang: l,
      confidence: CONFIDENCE
    )
    l
  end

  def ollama_translate(text, locale)
    t = Work::Text.for!(text)
    return t.lang.to_sym unless t.lang.nil?

    lang = LANGS[locale.to_sym]
    q = "your best translation of the following text to #{lang} without introduction or comment"
    ollama_query("#{q}:\n#{text}")
  end

  def ollama_translate_from_english(text, locale)
    lang = LANGS[locale.to_sym]
    # q = "
    #   Please translate the following text from english to #{lang} (no need to comment,
    #   just the plain translation please and return an empty string if you cannot translate it)
    # "
    q = "your best translation of the following text from english to #{lang} without introduction or comment"
    ollama_query("#{q}:\n#{text}")
  end

  def ollama_translate_with_html(text, locale)
    lang = LANGS[locale.to_sym]
    q = "
      Please translate this in #{lang} keeping html tags
      (no need to comment, just the translation please)
    "
    ollama_query("#{q}:\n#{text}")
  end
end
