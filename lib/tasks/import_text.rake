# frozen_string_literal: true

require 'async'
require 'digest'
require 'net/http'
require "openai"

class LanguageDetector
  attr_reader :model

  # rubocop:disable Layout/LineLength
  # DETECTLANG="can you tell if the following text is in english or french (no need to provide explaination, just the language) ?"
  # DETECTLANG="give me just the name of the language for the following text which might contain some embedded html"
  DETECTLANG = "what is the language of the following text which might be embedded into html or markdown, just answer with french or english"
  # rubocop:enable Layout/LineLength
  # model: meta-llama/Llama-3.3-70B-Instruct
  def initialize(model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16")
    @model = model
    @openai = OpenAI::Client.new(
      base_url: "https://inference-dev.rcp.epfl.ch/v1",
      api_key: ENV["OPENAI_API_KEY"]
    )
  end

  def detect(message)
    chat_completion = @openai.chat.completions.create(
      messages: [
        {
          role: :user,
          content: "#{DETECTLANG}\n#{message}"
        }
      ],
      model: "meta-llama/Llama-3.1-8B-Instruct-bfloat16"
    )
    res = chat_completion[:choices].first[:message][:content]
    case res
    when /english/i
      "en"
    when /french/i
      "fr"
    else
      "NA"
    end
  end
end

namespace :legacy do
  desc 'Copy to user_text table all the texts that need to be translated'
  task fetch_all_texts: :environment do
    roba = [
      { model: Legacy::Award, props: [:title] },
      { model: Legacy::Box, props: %i[content label] },
      { model: Legacy::Education, props: [:title] },
      { model: Legacy::Achievement, props: [:description] },
      { model: Legacy::Experience, props: [:title] }
    ].freeze
    done = Work::Text.all.pluck(:signature).index_with { |_k| true }
    Work::Sciper.migranda.pluck(:sciper).each do |sciper|
      puts sciper
      roba.each do |k|
        k[:model].where(sciper: sciper).find_each do |r|
          k[:props].each do |p|
            v = r.send(p)
            next if v.blank? || v.empty?

            s = Digest::MD5.hexdigest(v)
            next if done[s]

            Work::Text.create(
              signature: s,
              content: v
            )
            done[s] = true
          end
        end
      end
    end
  end

  desc 'Send text to AI for language detection'
  task txt_lang_detect: :environment do
    ld = LanguageDetector.new
    ib = 0
    Work::Text.wotrans.find_in_batches(batch_size: 20) do |wwtt|
      printf("batch %03d", ib)
      ib += 1
      tasks = wwtt.map do |wt|
        Async do
          [wt, ld.detect(wt.text_content)]
        end
      end
      results = tasks.map(&:wait)
      printf(".")
      results.each do |wt, lang|
        wt.ai_translations.create(
          ai_model: ld.model,
          lang: lang
        )
      end
      printf(".\n")
    end
  end
end
