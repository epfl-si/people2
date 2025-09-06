# frozen_string_literal: true

module Legacy
  SHITMAP = {
    "Ã¢" => "â",
    "Ã " => "à",
    "Ã¡" => "á",
    "Ã¤" => "ä",
    "Ã¥" => "å",
    "Ã£" => "ã",
    "Ã¨" => "è",
    "Ã©" => "é",
    "Ã‰" => "é",
    "Ä“" => "é",
    "Ãª" => "ê",
    "Ã«" => "ë",
    "Ã®" => "î",
    "Ã¯" => "î",
    "Ã­" => "í",
    "Ã" => "ï",
    "Ã²" => "ò",
    "Ã³" => "ó",
    "Ã´" => "ô",
    "Ã¶" => "ö",
    "Å“" => "œ",
    "Ã˜" => "Ø",
    "Ã¸" => "ø",
    "Ã»" => "û",
    "Ã¹" => "ù",
    "Ã¼" => "ü",
    "Ã§" => "ç",
    "Ä‡" => "ć",
    "ÃŸ" => "ß",
    "Å¡" => "š",
    "Î²" => "&beta;",
    "â€œ" => "«",
    "â€" => "»",
    "Â“" => "«",
    "Â”" => "»",
    "Â«" => "«",
    "Â»" => "»",
    "Â’" => "'",
    "â€™" => "'",
    "Â–" => "–",
    "â€¢" => "•",
    "â€“" => "&amp;",
    "Â©" => "&copy;",
  }.freeze

  POSSIBLE_ENCODINGS = [Encoding::UTF_8, Encoding::ISO_8859_1, Encoding::ASCII_8BIT, Encoding::Windows_1251].freeze

  # This function is probably just a dumber version of CharlockHolmes => useless
  def self.last_resort_deshit(c)
    Rails.logger.debug("Last resort deshittification for: #{c.truncate(60)}")
    POSSIBLE_ENCODINGS.each do |enc|
      return c.dup.force_encoding(enc).encode("UTF-8")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      Rails.logger.debug("failed with encoding #{enc}")
      next
    end
  end

  def self.deshit(text)
    return text unless text.is_a?(String)

    c = text.strip
    # Remove repeated br and spaces
    c.gsub!(/(<br>|&nbsp;)+/, "<br>")
    # Remove trailing br
    c.gsub!(/<br>\s*$/, "")
    c.gsub!(%r{</?div>}, "")

    char_deshit(c)
  end

  def self.char_deshit(c)
    # d = CharlockHolmes::EncodingDetector.detect(c)
    # if d.nil? || d[:confidence] < 95
    #   Rails.logger.debug("Slow deshittification required for: #{c.truncate(60)}")
    #   # Slow manual deshittification: replace stupid special chars
    #   SHITMAP.each_pair { |k, v| c.gsub!(k, v) }
    #   d = CharlockHolmes::EncodingDetector.detect(c)
    # end
    # CharlockHolmes detects UTF-8 even in presence of chars from SHITMAP
    # Therefore, fuckoff efficiency and let's manually deshittify in any case
    SHITMAP.each_pair do |k, v|
      c.gsub!(k, v)
    rescue StandardError
      Rails.logger.debug "Merda in #{c}"
      break
    end

    d = CharlockHolmes::EncodingDetector.detect(c)
    if d.nil?
      # probably a more sensible choice would be to just discard the bad string
      # and avoid filling the dabase with crap
      last_resort_deshit(c)
    else
      begin
        CharlockHolmes::Converter.convert c, d[:encoding], 'UTF-8'
      rescue ArgumentError
        last_resort_deshit(c)
      end
    end
  end

  class LegacyBase < ApplicationRecord
    self.abstract_class = true
    self.inheritance_column = :_type_disabled
    def readonly?
      true
    end
  end

  class BaseCv < LegacyBase
    self.abstract_class = true
    establish_connection :cv

    delegate :deshit, to: :Legacy

    # generic deshitter: attach the sanitize_ method to any string property
    def method_missing(name, *args, &block)
      ma = /^sanitized_([a-z]+)$/.match(name)
      super if ma.nil?
      method = ma[1]
      super unless respond_to?(method)
      method.is_a?(String) ? Legacy.deshit(send(method)) : method
    end

    def respond_to_missing?(name, include_private = false)
      ma = /^sanitized_([a-z]+)$/.match(name)
      if ma.nil?
        super
      else
        super(ma[1], include_private)
      end
    end
  end
end
