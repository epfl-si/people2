# frozen_string_literal: true

module ApplicationHelper
  # TODO: cleanup and use tag helpers consistently
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
      t(txt)
    end
  end

  # span with icon and text
  def icon_text(txt, icon)
    tag.span do
      content_tag(:svg,
                  content_tag(:use, "", { "xlink:href" => "##{icon}" }),
                  class: "icon text-icon") + t(txt)
    end
  end

  # icon + span with text
  def icon_label(txt, icon)
    res = content_tag(:svg, content_tag(:use, "", { "xlink:href" => "##{icon}" }), class: "icon text-icon")
    res << tag.span(t(txt), class: "label")
    res
  end

  def icon(icon)
    content_tag(:svg, content_tag(:use, "", { "xlink:href" => "##{icon}" }), class: "icon text-icon")
  end

  def profile_photo(picture, options = {})
    options = options.symbolize_keys
    tag_options = options.slice(:alt, :class, :id, :size)
    if picture.present? && (img = picture.image).present? && img.attached?
      rep_options = options.slice(:resize_to_limit, :resize_to_fit, :resize_to_fill, :resize_and_pad, :crop, :rotate)
      if rep_options.empty?
        image_tag(img, tag_options)
      else
        image_tag(img.representation(rep_options), tag_options)
      end
    else
      ph_src = options[:ph] || image_path('profile_image_placeholder.svg')
      image_tag(ph_src, tag_options)
    end
  end

  # <svg class="icon feather" aria-hidden="true"><use xlink:href="#activity"></use></svg>

  # Return the full url for static stuff coming from EPFL elements cdn
  def belurl(path)
    "https://web2018.epfl.ch/6.5.1/#{path}"
  end

  def language_switcher
    res = Rails.configuration.available_languages.map do |loc|
      content_tag(:li) do
        if I18n.locale.to_s == loc
          content_tag(:span, loc.to_s.upcase, class: "active", aria: { label: t(loc) })
        else
          link_to loc.to_s.upcase, { lang: loc.to_s }, aria: { label: t(loc) }
        end
      end
    end
    safe_join(res)
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

  # https://medium.com/@fabriciobonjorno/toast-with-stimulus-and-customized-error-messages-easily-and-quickly-0ff5e455ec80
  def errors_for(form, field)
    tag.p(form.object.errors[field].try(:first), class: 'text-danger ms-2 fw-medium')
  end

  def input_class_for(form, field)
    if form.object.errors[field].present?
      'form-control is-invalid'
    else
      'form-control'
    end
  end

  def error_alert(obj)
    return unless obj.errors.any?

    tag.div(class: "alert alert-danger show", role: "alert") do
      concat tag.p(t(errors_prevented_save))
      obj.errors.each do |error|
        concat tag.li(error.full_message)
      end
    end
  end

  # TODO: loader does not display
  def loader
    tag.span(clase: "loader", role: "status") do
      concat tag.span("Loading...", class: "sr-only")
    end
  end
end
