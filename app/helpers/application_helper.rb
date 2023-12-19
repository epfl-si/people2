# frozen_string_literal: true

module ApplicationHelper
  # forms for input phone: +41216937526, 0041216937526, 0216937526, 7526
  def phone_link(phone, opts = {})
    sep = '&nbsp;'
    p = phone.gsub(/ /, '').sub(/^00/, '+')
    if p.length > 5
      p = '+41' << p[1..9] if p =~ /^0/
    else
      p = "+412169#{p}"
    end
    p = '+41216931111' unless /^\+[0-9]{11}$/.match?(p)
    pl = p[0..2] << sep << p[3..4] << sep << p[5..7] << sep << p[8..9] << sep << p[10..11]
    # cp = @client_from_epfl ? 'tel' : 'callto'
    cp = "tel"
    # rubocop:disable Rails/OutputSafety
    link_to(pl.html_safe, "#{cp}:#{p}", opts)
    # rubocop:enable Rails/OutputSafety
  end

  def link_to_or_text(txt, url, opts = {})
    if url.present?
      link_to(txt, url, opts)
    else
      txt
    end
  end

  # Return the full url for static stuff coming from EPFL elements cdn
  def belurl(path)
    "https://epfl-si.github.io/elements/#{path}"
  end
end
