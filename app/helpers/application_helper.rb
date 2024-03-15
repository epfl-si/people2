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
    "https://web2018.epfl.ch/6.5.1/#{path}"
  end

  def language_switcher
    res = String.new
    {
      fr: "Français",
      en: "English",
    }.each do |loc, language|
      res << content_tag(:li) do
        if I18n.locale == loc
          content_tag(:span, loc.to_s.upcase, class: "active", aria: { label: language })
        else
          link_to loc.to_s.upcase, { lang: loc.to_s }, aria: { label: language }
        end
      end
    end
    # rubocop:disable Rails/OutputSafety
    res.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def fake_breadcrumbs(list = [])
    return if list.empty?

    content_for :breadcrumbs do
      tag.div(class: "breadcrumb-container") do
        tag.nav(class: "breadcrumb-wrapper", aria: { label: "breadcrumb" }) do
          tag.ol(class: "breadcrumb") do
            list[..-2].each do |v|
              concat tag.li(h(v), class: "breadcrumb-item")
            end
            concat tag.li(h(list.last), class: "breadcrumb-item active", aria: { current: "page" })
          end
        end
      end
    end
  end
end
