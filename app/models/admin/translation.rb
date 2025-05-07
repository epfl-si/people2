# frozen_string_literal: true

require 'fileutils'

module Admin
  class Translation < ApplicationRecord
    include Ollamable

    OTHER_LANGS = %w[fr it de].freeze
    ALL_LANGS = %w[en fr it de].freeze
    DL = ALL_LANGS.first
    establish_connection :work

    scope :forui, -> { where.not("key LIKE '%.placeholder.%' OR key LIKE '%lang.native.%'") }
    scope :todo, ->  { where(done: false) }
    validates :key, presence: true, uniqueness: { scope: :file }

    def autotranslate
      v = self[DL]
      OTHER_LANGS.each do |l|
        next unless self[l].nil?

        t = ollama_translate_from_english(v, l)

        next if t.blank?

        send("#{l}=", t)
      end
    end

    def autotranslate!
      autotranslate
      save
    end

    def self.reload_source_files
      d = Rails.root.join('config/locales').to_s
      ds = d.size
      IO.popen("find #{d} -name '#{DL}.yml'").readlines(chomp: true).each do |path|
        filename = path[ds..]
        ek = where(file: filename).pluck(:key).uniq.index_with { |_k| true }

        ref = TranslationsHash.load(path, DL)

        other = {}
        OTHER_LANGS.each do |l|
          op = File.dirname(path) + "/#{l}.yml"
          other[l] = TranslationsHash.load(op, l)
        end

        # new keys are added only in the en files => all the other are nil by construction
        ref.flat_keys.each do |k|
          v = ref.deep_get(k)
          next if v.blank?
          next if ek[k]

          params = {
            file: filename,
            key: k,
            done: false,
            auto: false,
          }
          params[DL] = v
          OTHER_LANGS.each do |l|
            params[l] = other[l].deep_get(k)
          end
          create!(params)
        end
      end
    end

    def self.zip_archive
      Translation.all.group_by(&:file).each do |file, translations|
        # path = src_d.join(file)
        path = Rails.root.join("config/locales/#{file}")
        ref = TranslationsHash.load(path, DL)
        ref.compact!
        # puts ref.h.to_yaml
        data = {}
        data[DL] = ref
        ALL_LANGS.each do |l|
          data[l] = ref.dup

          th = data[l]
          translations.each do |t|
            k = t.key
            v = t[l]
            th.deep_set(k, v)
          end
        end
        # prepend language to keys
        data.map do |k, v|
          v.compact!
          TranslationsHash.new({ k => v.h })
        end

        dir = Rails.root.join("tmp/locales/#{File.dirname(file)}")
        FileUtils.mkdir_p(dir)
        ALL_LANGS.each do |l|
          # data[l].compact!
          data[l].dump("#{dir}/#{l}.yml")
        end
        # puts data['fr'].deep_get("fr.achievements.form.year")

        # puts data[DL].h.to_yaml
      end
    end
  end
end

# index -> buton for refreshing translations from file
#          load en files, extract all keys,
#          check existence in db and create missing translations
#
#       -> sortable table with key, reference value (en),
#          check where translation exists, last created/date (to see newly added)
#       -> crud form
#       -> validate button for saying that the translation is fully checked
#       -> a route to dump translation files archive
