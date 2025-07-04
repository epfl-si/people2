# frozen_string_literal: true

module BackofficeHelper
  def form_group(help: nil, **opts, &block)
    c = []
    c << tag.div(class: "form-group #{opts[:extracls]}") do
      capture(&block)
    end
    c << tag.small(help, class: "form-text text-muted") if help.present?
    safe_join c
  end

  def label_and_help(form, attr, label: nil, help: nil, **opts)
    tlabel = t(label || "helpers.label.#{form.object.model_name.element}.#{attr}")
    ahelp = help || t("generic.form.texfield_for", attr: tlabel)
    tlabel = "#{tlabel} *" if opts[:required]
    [tlabel, ahelp]
  end

  def single_text_field(form, attr, label: nil, help: nil, show_label: true, **opts)
    # Normally, it is not necessary to send the translated label to the label
    # helper because it can do it by itself if the corresponding translation
    # (helpers.label.obj_name.attribute) is provided. But we want to use the
    # lable also in the aria-described-by. Therefore, we precompute it.
    tlabel, ahelp = label_and_help(form, attr, label: label, help: help, **opts)
    c = []
    c << form.label(attr, tlabel) if show_label
    c << form.text_field(
      attr, opts.merge(placeholder: true, class: "form-control", "aria-describedby": ahelp)
    )
    form_group(help: help, **opts) { safe_join(c) }
  end

  def single_text_area(form, attr, label: nil, help: nil, show_label: true, **opts)
    tlabel, ahelp = label_and_help(form, attr, label: label, help: help, **opts)
    c = []
    c << form.label(attr, tlabel) if show_label
    c << form.text_area(
      attr, opts.merge(class: "form-control", "aria-describedby": ahelp)
    )
    form_group(help: help, **opts) { safe_join(c) }
  end

  def form_label(form, attr, label: nil, **opts)
    tlabel, = label_and_help(form, attr, label: label, **opts)
    form.label(attr, tlabel)
  end

  def single_rich_text_area(form, attr, label: nil, help: nil, show_label: true, **opts)
    tlabel, = label_and_help(form, attr, label: label, help: help, **opts)
    c = []
    c << form.label(attr, tlabel) if show_label
    c << rich_text_input(form, attr)
    form_group(help: help, **opts) { safe_join(c) }
  end

  def single_number_field(form, attr, min: nil, max: nil, label: nil, help: nil, **opts)
    tlabel, ahelp = label_and_help(form, attr, label: label, help: help, **opts)
    c = []
    c << form.label(attr, tlabel)
    c << form.number_field(
      attr, opts.merge(min: min, max: max, class: "form-control", "aria-describedby": ahelp)
    )
    form_group(help: help, **opts) { safe_join(c) }
  end

  def range_number_field(
    form,
    attr_a, attr_b,
    help: nil,
    label: "period",
    min: nil, max: nil,
    **opts
  )
    tlabel, ahelp = label_and_help(form, attr_a, label: label, help: help, **opts)
    f = [
      form.number_field(attr_a, min: min, max: max, class: "form-control", "aria-describedby": ahelp),
      sanitize("&nbsp;&mdash;&nbsp;"),
      form.number_field(attr_b, min: min, max: max, class: "form-control", "aria-describedby": ahelp)
    ]
    c = []
    c << form.label(attr_a, tlabel)
    c << tag.div { safe_join(f) }
    form_group(help: help, **opts) { safe_join(c) }
  end

  def single_url_field(form, attr, label: nil, help: nil, **opts)
    tlabel, ahelp = label_and_help(form, attr, label: label, help: help, **opts)
    c = []
    c << form.label(tlabel)
    c << form.url_field(attr, class: "form-control", "aria-describedby": ahelp)
    form_group(help: help, **opts) { safe_join(c) }
  end

  def property_select(form, prop, collection, label: nil, help: nil, **opts)
    attr = "#{prop}_id".to_sym
    tlabel, ahelp = label_and_help(form, prop, label: label, help: help, **opts)
    c = []
    c << form.label(attr, tlabel)
    c << form.collection_select(attr, collection, :id, :t_name, {},
                                { "aria-describedby": ahelp, class: "custom-select" })
    form_group(help: help, **opts) { safe_join(c) }
  end

  def translated_text_fields(
    form, attr, label: nil, help: nil, show_label: true, **opts
  )
    translations = translations_for(form.object)
    btlabel = t(label || "helpers.label.#{form.object.model_name.element}.#{attr}")

    monolang = (translations.count == 1)
    required = monolang ? opts[:required] : opts.delete(:required)

    content = []
    translations.each do |l|
      tlang = t("lang.#{l}")
      # Attribute for language l
      tattr = "#{attr}_#{l}"
      # Translated label for language l
      tlabel = t("translated_label", language: tlang, label: btlabel)
      ahelp = help || t("generic.form.translated_texfield_for", language: tlang, attr: tlabel)
      tlabel = safe_join([tlabel, mandatory(translated: !monolang)]) if required
      c = []
      c << form.label(tattr, tlabel) if show_label
      c << form.text_field(tattr, opts.merge(placeholder: true, class: "form-control", "aria-describedby": ahelp))
      content << form_group(help: help, extracls: "tr_target_#{l}", **opts) { safe_join(c) }
    end
    safe_join(content)
  end

  def translated_rich_text_areas(form, attr, label: nil, help: nil, show_label: true, **opts)
    translations = translations_for(form.object)
    btlabel = t(label || "helpers.label.#{form.object.model_name.element}.#{attr}")

    content = []
    translations.each do |l|
      tlang = t("lang.#{l}")
      tattr = "#{attr}_#{l}"
      tlabel = t("translated_label", language: tlang, label: btlabel)
      c = []
      c << form.label(tlabel) if show_label
      c << rich_text_input(form, tattr)
      content << form_group(help: help, extracls: "tr_target_#{l}", **opts) { safe_join(c) }
    end
    safe_join(content)
  end

  # TODO: it would be nice to have a popover explaining the meaning of the *, **
  # def popover_text(content, text)
  #   c = []
  #   c << tag.span(text, class: 'popover-anchor')
  #   c << tag.span(content, popover: true)
  #   safe_join(c)
  # end
  #
  # def mandatory(translated: false)
  #   if translated
  #     popover_text(t("generic.form.mandatory"), "**")
  #   else
  #     popover_text(t("generic.form.mandatory"), "*")
  #   end
  # end
  def mandatory(translated: false)
    sanitize(translated ? "&nbsp; **" : "&nbsp; *")
  end

  def translations_for(obj)
    if obj.respond_to?("translations")
      obj.translations
    elsif obj.respond_to?("profile")
      obj.send("profile").translations
    else
      I18n.available_locales
    end
  end

  def localized_attr_value(obj, attr, locale)
    v = obj.send("#{attr}_#{locale}")
    if v.blank?
      a = t("activerecord.attributes.#{obj.class.name.underscore}.#{attr}")
      l = t("lang.#{locale}")
      v = t("no_attribute_for_locale", attribute: a, language: l)
    end
    v
  end

  def tag_for_localized_attr(tag_name, obj, attr, params = {})
    translations = params[:translations] || translations_for(obj)
    cls = params.delete(:class)
    content = translations.map do |l|
      params[:class] = cls.nil? ? "tr_target_#{l}" : "#{cls} tr_target_#{l}"
      v = obj.send("#{attr}_#{l}")
      if v.blank?
        a = t("activerecord.attributes.#{obj.class.name.underscore}.#{attr}")
        l = t("lang.#{l}")
        v = t("no_attribute_for_locale", attribute: a, language: l)
        params[:class] << " user_translation_missing"
      end
      content_tag(tag_name, v, params)
    end
    safe_join(content)
  end

  def rich_text_input(form, attr)
    cls = if Rails.configuration.enable_direct_uploads
            "rich_text_input"
          else
            "rich_text_input disable-trix-file-attachment"
          end
    tag.div form.rich_text_area(attr), class: cls
  end

  def attribute_switch(form, attr, label: nil)
    id = "ck_#{form.object_name.gsub(/[^a-z0-9]+/, '_').gsub(/_$/, '')}_#{attr}"
    tlabel = t(label || ".#{attr}")
    tag.div(class: 'custom-control custom-checkbox') do
      form.check_box(attr, class: 'custom-control-input', id: id) +
        form.label(tlabel, class: "custom-control-label", for: id)
    end
  end

  def item_translations(item)
    if item.respond_to?("translations")
      item.translations
    elsif item.respond_to?("profile")
      item.profile.translations
    else
      I18n.available_locales
    end
  end

  def all_lang_span(item, attr, languages: nil)
    languages ||= item_translations(item)
    c = languages.map do |l|
      tag.span(item.send("#{attr}_#{l}"), class: "tr_target_#{l}")
    end
    safe_join(c)
  end

  def translation_list(profile)
    profile.translations.join(" ")
  end

  def current_work_translation(item)
    tt = item_translations(item)
    if tt.include?(I18n.locale.to_s)
      I18n.locale.to_s
    else
      tt.first
    end
  end

  def translation_classlist(item)
    # this is if we want to enable all languages by default
    # profile.translations.map { |t| "tr_enable_#{t}" }.join(" ")
    # this is if we want to have the current locale or the first of the list
    t = current_work_translation(item)
    "tr_enable_#{t}"
  end

  def common_editor(title: nil, &block)
    c1 = []
    # TODO: not nice to have an empty h3 but without it the close button will no
    #       longer stay on the right. No time to fight with CSS and fix this now
    c1 << tag.h3(title) # if title.present?
    c1 << tag.button(
      "✕",
      type: "button",
      class: "btn btn-link text-danger fs-4 p-0 ms-2 float-end",
      data: { action: "click->dismissable#dismiss" },
      aria: { label: I18n.t("action.cancel") }
    )

    c = []
    c << tag.div(class: "d-flex align-items-center justify-content-between mb-2") do
      safe_join(c1)
    end
    c << tag.div(capture(&block))
    c = tag.div(class: "container") do
      safe_join(c)
    end

    safe_join [
      tag.div("", id: "editor_overlay", class: "modal-overlay"),
      turbo_stream.update("editor") { tag.div(c, id: "editor_content") },
      turbo_stream.replace("flash-messages", partial: "shared/flash")
    ]
  end

  def dismiss_common_editor
    safe_join [
      turbo_stream.update("editor") { "" },
      turbo_stream.replace("flash-messages", partial: "shared/flash")
    ]
  end

  def form_actions(form, item, without_cancel: false, label: nil, submit_label: nil, cancel_label: nil, &block)
    item.class.name.underscore
    c = []
    c << capture(&block) if block_given?
    submit_label ||= item.new_record? ? t("generic.form.create", label: label) : t("generic.form.update", label: label)
    cancel_label ||= t("action.dismiss")

    unless without_cancel
      c << tag.button(cancel_label, class: "btn btn-cancel",
                                    "data-action": "click->dismissable#dismiss")
    end
    c << form.submit(submit_label, class: "btn-confirm")
    tag.div(class: "form-actions") do
      safe_join(c)
    end
  end

  def add_record_button(url, name: nil)
    tag.div(class: "row justify-content-center add-buttons") do
      label_text = name.nil? ? t('action.add') : t('action.add_record', name: t("activerecord.models.#{name}"))

      link_to url,
              method: :get,
              data: { turbo_stream: true, turbo_method: 'get' },
              class: "btn-push" do
        safe_join([
                    tag.span("", class: "btn-push-shadow"),
                    tag.span("", class: "btn-push-edge"),
                    tag.span(class: "btn-push-front text") do
                      safe_join([icon("plus"), " ", label_text])
                    end
                  ])
      end
    end
  end

  def visibility_switch(form)
    id = form.object_name.gsub(/[^a-z0-9]+/, "_").gsub(/_$/, '')
    tag.div(class: 'custom-control custom-checkbox') do
      concat form.check_box(:visible, class: 'custom-control-input', id: id)
      concat form.label(
        form.object.class.send(:human_attribute_name, "visible"),
        class: "custom-control-label",
        for: id
      )
    end
  end

  def visibility_icon_button(item)
    # tag.button(
    #   icon(item.visibility_option.icon),
    #   class: "btn btn-secondary btn-sm visibility-toggle-button",
    #   data: {action: "mouseenter->popover#show mouseleave->popover#hide" },
    # )
    o = item.visibility_option
    title = t "visibility.short_label.#{o.label}"
    tag.div(
      class: "visibility-button",
      data: { action: "mouseenter->popover#show mouseleave->popover#hide" }
    ) do
      safe_join([
                  icon(o.icon),
                  tag.span(title, class: "label")
                ])
    end
  end

  def visibility_binary_selector(form, item, property: nil, with_stimulus: true)
    prop = property.nil? ? "visibility" : "#{property}_visibility"
    stim_data = { action: 'input->auto-submit#submit' }

    o = item.send("#{prop}_option")
    id = "#{dom_id(item, prop.to_sym)}_#{o.value}"
    title = t "visibility.label.#{o.label}"
    label_data = { label: title }
    tag.div(class: "binary-switch") do
      content = []
      content << form.hidden_field(:property, value: property) if property.present?
      content << form.hidden_field(:visibility, value: o.next)
      content << form.checkbox(
        :enabled,
        id: id,
        class: "checkbox",
        checked: o.lit,
        data: (with_stimulus ? stim_data.merge(label_data) : label_data)
      )
      content << tag.label(for: id)
      content << tag.span(t("visibility.label.#{o.label}"), class: "bslabel")
      safe_join(content)
    end
  end

  def visibility_multiple_selector(form, item, property: nil, with_stimulus: true)
    prop = property.nil? ? "visibility" : "#{property}_visibility"
    options = item.send("#{prop}_options")
    id0 = dom_id(item, prop.to_sym)
    stim_data = { action: 'input->auto-submit#submit' }
    content = []
    content << form.hidden_field(:property, value: property) if property.present?
    options.each do |o|
      id = "#{id0}_#{o.value}"
      title = t "visibility.label.#{o.label}"
      label_data = { label: title }
      content << form.radio_button(
        :visibility, o.value,
        id: id,
        class: "radio-#{o.style}",
        data: (with_stimulus ? stim_data.merge(label_data) : label_data),
        checked: item.send(prop) == o.value
      )
      content << form.label("visibility_#{o.value}".to_sym, tag.span(icon(o.icon)), for: id, title: title)
    end
    content = safe_join(content)
    tag.div(content, class: "visibility-radios")
  end

  def visibility_selector(form, item, property: nil, with_stimulus: true)
    # item = form.object
    prop = property.nil? ? "visibility" : "#{property}_visibility"
    options = item.send("#{prop}_options")
    if options.count == 2
      visibility_binary_selector(form, item, property: property, with_stimulus: with_stimulus)
    else
      visibility_multiple_selector(form, item, property: property, with_stimulus: with_stimulus)
    end
  end

  def visibility_tag(item, property: nil)
    if property.present?
      o = item.send("#{property}_visibility_option")
      ta = item.class.human_attribute_name(property)
    else
      o = item.send("visibility_option")
      ta = item.model_name.human
    end
    prop = property.nil? ? "visibility" : "#{property}_visibility"
    o = item.send("#{prop}_option")
    tag.span(class: 'visibility') do
      icon_text(o.icon, t("visibility.tag.#{o.label}", item: ta))
    end
  end

  def remote_modal_for(uri, &block)
    content = capture(&block)
    link_to content, uri, data: { turbo_frame: :remote_modal }
  end

  def modal_dialog(title, _id = :remote_modal, &block)
    content = capture(&block)
    button = tag.button(type: "button", class: "close", data: { action: "click->remote-modal#close" }) do
      tag.span(sanitize("&times;"), "aria-hidden": true)
    end

    turbo_frame_tag :remote_modal do
      tag.dialog(
        "aria-labelledby": "modal_title",
        "data-controller": "remote-modal"
      ) do
        tag.div(class: "modal-content") do
          safe_join([
                      tag.div(class: "modal-header") { safe_join([tag.h5(title, id: "modal_title"), button]) },
                      turbo_frame_tag(:remote_modal_body, class: "modal-body") { content }
                    ])
        end
      end
    end
  end
end
