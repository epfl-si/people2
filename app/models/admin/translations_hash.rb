# frozen_string_literal: true

module Admin
  class TranslationsHash
    attr_reader :h

    def self.load(path, key = nil)
      if File.exist?(path)
        d = YAML.load_file(path, aliases: true)
        if key.nil?
          new(d)
        else
          new(d[key])
        end
      else
        new({})
      end
    end

    def dump(path = nil)
      if path.nil?
        @h.to_yaml
      else
        File.open(path, "w") { |file| file.write(@h.to_yaml) }
      end
    end

    def initialize(hash)
      @h = hash
    end

    def f
      @f ||= h_deep_flatten(@h)
    end

    def dup
      # TODO: for some reason this does not work although
      #       in rails we could use the deep_dup extension
      #       TranslationsHash.new(@h.deep_dup)
      # TranslationsHash.new(h_deep_dup(@h))
      TranslationsHash.new(YAML.load(@h.to_yaml))
    end

    def compact!
      @f.compact! if defined?(@f)
      h_deep_compact(@h)
    end

    def deep_set(key, value)
      return if f[key] == value

      f[key] = value

      kk = key.split('.')
      kl = kk.pop
      h = @h
      kk.each do |k|
        h[k] = {} unless h.key?(k)
        h = h[k]
      end
      h[kl] = value

      # v0 = f[key]
      # k = key.split(".")
      # v1 = @h.dig(*k)
      # puts "v0=#{v0} <=> v1=#{v1}" unless v0==v1 and v0 == value
    end

    def deep_get(key)
      f[key]
      # k = key.split(".")
      # @h.dig(*k)
    end

    def flat_each(&block)
      f.each(&block)
    end

    def flat_keys
      f.keys
    end

    private

    def h_deep_flatten(hash, fh = {}, prefix = nil)
      hash.map do |k, v|
        kk = prefix ? "#{prefix}.#{k}" : k
        if v.is_a?(Hash)
          h_deep_flatten(v, fh, kk)
        else
          fh[kk] = v
        end
      end
      fh
    end

    def h_deep_compact(hash)
      hash.each_value do |v|
        h_deep_compact(v) if v.is_a? Hash
      end
      hash.compact!
    end

    def h_deep_dup(src)
      return src unless src.is_a?(Hash)

      hash = {}
      src.each do |key, value|
        hash[key] = if value.is_a?(Hash)
                      h_deep_dup(value)
                    else
                      value
                    end
      end
      hash
    end
  end
end
