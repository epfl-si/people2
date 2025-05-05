# frozen_string_literal: true

module Admin
  class Translation < ApplicationRecord
    establish_connection :work
    validates :key, presence: true, uniqueness: { scope: :file }

    def self.reload_source_files
      d = Rails.root.join('config/locales').to_s
      ds = d.size
      IO.popen("find #{d} -name 'en.yml'").readlines(chomp: true).each do |path|
        filename = path[ds..]
        ek = where(file: filename).pluck(:key).uniq.index_with { |_k| true }
        d_en = YAML.load_file(path, aliases: true)
        f_en = hash_flatten(d_en)

        # new keys are added only in the en files => all the other are nil by construction
        f_en.each_key do |k|
          next unless k.start_with?('en')

          v = f_en[k]
          next if v.blank?

          kk = k[3..]
          next if ek[kk]

          create!(
            file: filename,
            key: kk,
            en: f_en[k],
            fr: nil,
            it: nil,
            de: nil,
            done: false
          )
        end
      end
    end

    def self.hash_flatten(hash, fh = {}, prefix = nil)
      hash.map do |k, v|
        kk = prefix ? "#{prefix}.#{k}" : k
        if v.is_a?(Hash)
          hash_flatten(v, fh, kk)
        else
          fh[kk] = v
        end
      end
      fh
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
