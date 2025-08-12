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
  }.freeze

  POSSIBLE_ENCODINGS = [Encoding::UTF_8, Encoding::ISO_8859_1, Encoding::ASCII_8BIT, Encoding::Windows_1251].freeze

  def self.last_resort_deshit(c)
    Rails.logger.debug("String with failed CharlockHolmes (undetected of failed): #{c.truncate(120)}")
    POSSIBLE_ENCODINGS.each do |enc|
      return c.dup.force_encoding(enc).encode("UTF-8")
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
      next
    end
    # we could probably skip the next line but, since I spent a lot of time
    # collecting as many shitty chars as possible from the legacy DB...
    SHITMAP.each_pair { |k, v| c.gsub!(k, v) }
    c.encode("UTF-8", invalid: :replace, undef: :replace)
  end

  def self.deshit(text)
    return text unless text.is_a?(String)

    c = text.strip
    # Remove repeated br and spaces
    c.gsub!(/(<br>|&nbsp;)+/, "<br>")
    # Remove trailing br
    c.gsub!(/<br>\s*$/, "")
    c.gsub!(%r{</?div>}, "")

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
