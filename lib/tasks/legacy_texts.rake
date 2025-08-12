# frozen_string_literal: true

require 'async'
require 'digest'
require 'net/http'
require "openai"

namespace :legacy do
  task reload_texts: %i[nuke_texts fetch_all_texts] do
  end

  desc 'Nuke collection of legacy texts from Work::Text table'
  task nuke_texts: :environment do
    Work::Text.in_batches(of: 1000).delete_all
  end

  desc 'Copy to user_text table all the texts that need to be translated'
  task load_texts: :environment do
    roba = [
      { model: Legacy::Award, props: [:title] },
      { model: Legacy::Box, props: %i[ok_content label] },
      { model: Legacy::Education, props: [:title] },
      # { model: Legacy::Achievement, props: [:description] },
      { model: Legacy::Experience, props: [:title] }
    ].freeze
    done = Work::Text.all.pluck(:signature).index_with { |_k| true }
    st = Work::Sciper.migranda.count
    sd = 0
    Work::Sciper.migranda.pluck(:sciper).each do |sciper|
      sd += 1
      printf "%06<sd>d / %06<st>d : %<sciper>s\n", sd: sd, st: st, sciper: sciper
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
    ld = AiAgent.new
    ib = 0
    Work::Text.wotrans.find_in_batches(batch_size: 20) do |wwtt|
      printf("batch %03d", ib)
      ib += 1
      results = ld.batch_with_object(:detect_language, :text_content, wwtt)
      printf(".")
      results.each do |wt, r|
        wt.ai_translations.create(
          ai_model: ld.model,
          lang: r.res,
          confidence: r.confidence
        )
      end
      printf(".\n")
    end
  end

  # FIX: this blocks after few iterations. We need to add timeout somewhere. May
  #      be it depends on the size of the batch. It is also slower than expected
  #      to submit the jobs. May be it is simply not running in parallel...:o
  desc 'Send text to AI for translation'
  task txt_translate: :environment do
    ld = AiAgent.new
    ib = 0
    %w[en fr].each do |loc|
      Work::AiTranslation.where("content_#{loc}": nil)
                         .where.not(lang: loc)
                         .includes(:text)
                         .find_in_batches(batch_size: 5) do |wwtt|
        printf("batch %03d", ib)
        ib += 1
        results = ld.batch_with_object(:translate_with_html, :content, wwtt, loc)
        printf(".")
        results.each do |wt, r|
          wt.send("content_#{loc}=", r.res)
          wt.save
        end
        printf(".\n")
      end
    end
  end
end
