# frozen_string_literal: true

require 'async'
require "openai"

class AiAgent
  LANGS = {
    en: "english",
    fr: "french",
    it: "italian",
    de: "german"
  }.freeze

  attr_reader :model

  # model: meta-llama/Llama-3.3-70B-Instruct
  def initialize(model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16")
    @model = model
    @openai = OpenAI::Client.new(
      base_url: "https://inference-dev.rcp.epfl.ch/v1",
      api_key: ENV["OPENAI_API_KEY"]
    )
  end

  def detect_language(message)
    q = "what is the language of the following text which might be "\
        "embedded into html or markdown, just answer with french or english"
    chat = @openai.chat.completions.create(
      messages: [
        {
          role: :user,
          content: "#{q}\n#{message.truncate(400)}"
        }
      ],
      model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16"
    )
    confidence = 0.5
    res = chat[:choices].first[:message][:content]
    case res
    when /english/i
      OpenStruct.new(lang: "en", confidence: confidence)
    when /french/i
      OpenStruct.new(lang: "fr", confidence: confidence)
    when /italian/i
      OpenStruct.new(lang: "it", confidence: confidence)
    when /german/i
      OpenStruct.new(lang: "de", confidence: confidence)
    else
      OpenStruct.new(lang: nil, confidence: 0.0)
    end
  end

  def translate(message, locale)
    lang = LANGS[locale.to_sym]
    q = "just your best translation of the following text to #{lang} without "\
        "introduction or comment"
    chat = @openai.chat.completions.create(
      messages: [
        {
          role: :user,
          content: "#{q}\n#{message}"
        }
      ],
      model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16"
    )
    res = chat[:choices].first[:message][:content]
    OpenStruct.new(res: res, confidence: 0.5)
  end

  def translate_with_html(message, locale)
    lang = LANGS[locale.to_sym]
    q = "just your best translation of the following text to #{lang} keeping "\
        "html tags if any (no need to comment, just the translation please)"
    chat = @openai.chat.completions.create(
      messages: [
        {
          role: :user,
          content: "#{q}\n#{message}"
        }
      ],
      model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16"
    )
    res = chat[:choices].first[:message][:content]
    OpenStruct.new(res: res, confidence: 0.5)
  end

  def ciccio(msg)
    i = rand(1..4)
    sleep(i)
    "#{msg.upcase} -> #{i}"
  end

  # SIMD version of one of the above methods.
  #  args is a vector
  #  params is an optional list of parameters that will be passed to the method
  #  for each element of the vector. Example, to translate a list of messages
  #  all in the same language: batch(:translate, [msg1, msg2, ... msgn], "en")
  #  If different parameters are needed for each
  #  element of the vector then one can make args a vector of vectors. For
  #  example to translate a list of messages each in its own language:
  #  batch(:translate, [[msg1, "en", [msg2, "fr"], [msg3, "fr"], [msg4, "en"]]
  def batch(method, args, *params)
    Sync do
      tasks = args.map do |arg|
        Async do
          send(method, *arg, *params)
        end
      end
      tasks.map(&:wait)
    end
  end

  # SIMD version of one of the above methods but instead of passing the input
  # for the method, it expects objects on which it will call object_methopd
  # in order to the actual input for the method. The result will be a list
  # of [original_object, result]
  def batch_with_object(method, object_method, objects, *params)
    Sync do
      tasks = objects.map do |obj|
        Async do
          [obj, send(method, obj.send(object_method), *params)]
        end
      end
      tasks.map(&:wait)
    end
  end
end
