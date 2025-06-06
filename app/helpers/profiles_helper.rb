# frozen_string_literal: true

module ProfilesHelper
  def profile_text_field(form, attr, placeholder)
    lb = form.label form.object.class.send(:human_attribute_name, attr), class: "col-sm-3  col-form-label"
    fd = tag.div(class: "col-sm-9") do
      form.text_field attr, class: "form-control", placeholder: placeholder
    end
    lb + fd
  end

  def form_group(help: nil, extracls: "", &block)
    c = []
    c << tag.div(class: "form-group #{extracls}") do
      capture(&block)
    end
    c << tag.small(help, class: "form-text text-muted") if help.present?
    safe_join c
  end

  def single_text_field(form, attr, label: nil, help: nil, extracls: "", tabindex: nil)
    a = attr.to_sym
    tlabel = label || ".#{attr}"
    ahelp = help || t("generic.form.texfield_for", attr: t(tlabel))
    form_group(help: help, extracls: extracls) do
      form.label(t(tlabel)) +
        form.text_field(
          a, placeholder: true, class: "form-control", "aria-describedby": ahelp, tabindex: tabindex
        )
    end
  end

  def single_number_field(form, attr, min: nil, max: nil, label: nil, help: nil, extracls: "")
    a = attr.to_sym
    tlabel = label || ".#{attr}"
    ahelp = help || t("generic.form.texfield_for", attr: t(tlabel))
    form_group(help: help, extracls: extracls) do
      form.label(t(tlabel)) +
        form.number_field(
          a, min: min, max: max, class: "form-control", "aria-describedby": ahelp
        )
    end
  end

  def range_number_field(
    form,
    attr_a, attr_b,
    label,
    min: nil, max: nil,
    help: nil,
    extracls: ""
  )
    a = attr_a.to_sym
    b = attr_b.to_sym

    form_group(help: help, extracls: extracls) do
      form.label(t(label)) +
        tag.div do
          form.number_field(a, min: min, max: max, class: "form-control") +
            "&nbsp;&mdash;&nbsp;".html_safe +
            form.number_field(b, min: min, max: max, class: "form-control")
        end
    end
  end

  def single_url_field(form, attr, label: nil, help: nil, extracls: "")
    sattr = attr.to_sym
    tlabel = label || ".#{attr}"
    ahelp = help || t("generic.form.texfield_for", attr: t(tlabel))
    form_group(help: help, extracls: extracls) do
      form.label(t(tlabel)) +
        form.url_field(sattr, class: "form-control", "aria-describedby": ahelp)
    end
  end

  def translated_text_fields(
    form, attr, label: nil, help: nil,
    translations: I18n.available_locales
  )
    content = []
    btlabel = t(label || ".#{attr}")
    translations.each do |l|
      tlang = t("lang.#{l}")
      # Attribute for language l
      tattr = "#{attr}_#{l}"
      # Translated label for language l
      tlabel = t("translated_label", language: tlang, label: btlabel)
      ahelp = help || t("generic.form.texfield_for", attr: tlabel)
      label = form.label(tlabel)
      text_field = form.text_field(tattr, placeholder: true, class: "form-control", "aria-describedby": ahelp)
      content << form_group(help: help, extracls: "tr_target_#{l}") do
        label + text_field
      end
    end
    safe_join(content)
  end

  def translations_for(obj)
    if obj.respond_to?("profile")
      obj.send("profile").translations
    else
      Rails.available_languages
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

  def single_rich_text_area(form, attr, label: nil, extracls: "")
    attr.to_sym
    form_group(extracls: extracls) do
      form.label(t(label || ".#{attr}")) + rich_text_input(form, attr)
    end
  end

  def translated_rich_text_areas(
    form, attr, label: nil, help: nil,
    translations: I18n.available_locales
  )
    content = []
    btlabel = t(label || ".#{attr}")
    translations.each do |l|
      tlang = t("lang.#{l}")
      tattr = "#{attr}_#{l}"
      # Attribute for language l
      # Translated label for language l
      tlabel = t("translated_label", language: tlang, label: btlabel)
      label = form.label(tlabel)
      tarea = rich_text_input(form, tattr)
      content << form_group(help: help, extracls: "tr_target_#{l}") do
        label + tarea
      end
    end
    safe_join(content)
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
    c = []
    c << tag.hr
    c << tag.h3(title) if title.present?
    c << tag.div(capture(&block))
    c1 = tag.div(class: "container") do
      safe_join(c)
    end
    safe_join [
      turbo_stream.update("editor_content") { c1 },
      turbo_stream.replace("flash-messages", partial: "shared/flash")
    ]
  end

  def dismiss_common_editor
    safe_join [
      turbo_stream.update("editor_content") { "" },
      turbo_stream.replace("flash-messages", partial: "shared/flash")
    ]
  end

  def form_actions(form, item, without_cancel: false, label: nil, submit_label: nil, &block)
    item.class.name.underscore
    c = []
    c << capture(&block) if block_given?
    submit_label ||= item.new_record? ? t("generic.form.create", label: label) : t("generic.form.update", label: label)

    unless without_cancel
      c << tag.button(t("action.dismiss"), class: "btn btn-cancel",
                                           "data-action": "click->dismissable#dismiss")
    end
    c << form.submit(submit_label, class: "btn-confirm")
    tag.div(class: "form-actions") do
      safe_join(c)
    end
  end

  def add_record_button(url, name: nil)
    tag.div(class: "row justify-content-center") do
      if name.nil?
        link_to icon_text('plus-circle', t('action.add')), url, class: "btn btn-secondary btn-sm",
                                                                data: { turbo_stream: true }
      else
        link_to(
          icon_text(
            'plus-circle',
            t('action.add_record', name: t("activerecord.models.#{name}"))
          ),
          url,
          class: "btn btn-secondary btn-sm",
          data: { turbo_stream: true }
        )
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

  def visibility_selector(form, item, property: nil, with_stimulus: true)
    # item = form.object
    prop = property.nil? ? "visibility" : "#{property}_visibility"
    id0 = dom_id(item, prop.to_sym)
    stim_data = { action: 'input->auto-submit#submit' }
    content = []
    content << form.hidden_field(:property, value: property) if property.present?
    item.send("#{prop}_options").each do |o|
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

  def remote_modal_for(uri, &block)
    content = capture(&block)
    link_to content, uri, data: { turbo_frame: :remote_modal }
  end

  def modal_dialog(title, _id = :remote_modal, &block)
    content = capture(&block)
    button = tag.button(type: "button", class: "close", data: { action: "click->remote-modal#close" }) do
      tag.span("&times;".html_safe, "aria-hidden": true)
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
