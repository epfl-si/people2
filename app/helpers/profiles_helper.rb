# frozen_string_literal: true

module ProfilesHelper
  def profile_text_field(form, attr, placeholder)
    lb = form.label form.object.class.send(:human_attribute_name, attr), class: "col-sm-3  col-form-label"
    fd = tag.div(class: "col-sm-9") do
      form.text_field attr, class: "form-control", placeholder: placeholder
    end
    lb + fd
  end

  def single_text_field(form, field, label: nil, extracls: "")
    a = field.to_sym
    oc = form.object.class
    tag.div(class: "form-group #{extracls}") do
      form.label(t(label||field)) + form.text_field(a, placeholder: true)
    end
  end

  def translated_text_fields(
        form, field, label: nil,
        translations: Rails.configuration.available_languages
      )
    content = translations.map do |l|
      single_text_field(form, "#{field}_#{l}", label: "#{label||field}_#{l}", extracls: "tr_target_#{l}")
    end
    safe_join(content)
  end

  def rich_text_input(form, property)
    cls = if Rails.configuration.enable_direct_uploads
            "rich_text_input"
          else
            "rich_text_input disable-trix-file-attachment"
          end
    tag.div form.rich_text_area(property), class: cls
  end

  def single_rich_text_area(form, field, label: nil, extracls: "")
    a = field.to_sym
    tag.div(class: "form-group #{extracls}") do
      form.label(t(label||field)) + rich_text_input(form, field)
    end
  end

  def translated_rich_text_areas(
        form, field, label: nil,
        translations: Rails.configuration.available_languages
      )
    content = translations.map do |l|
      single_rich_text_area(form, "#{field}_#{l}", label: "#{label||field}_#{l}", extracls: "tr_target_#{l}")
    end
    safe_join(content)
  end

  def translation_list(profile)
    profile.translations.join(" ")
  end

  def translation_classlist(profile)
    profile.translations.map { |t| "tr_enable_#{t}" }.join(" ")
  end

  def form_actions(form, item, without_cancel: false, label: nil, &block)
    klass = item.class.name.underscore
    tag.div(class: "form-actions") do
      concat capture(&block) if block_given?
      if item.new_record?
        concat form.submit t("action.create_#{klass}", label: label), class: "btn-confirm"
      else
        unless without_cancel
          concat link_to(t('action.cancel'),
                         send("#{klass}_path", item),
                         class: "btn-cancel", method: :get,
                         data: { turbo_stream: true, turbo_method: 'get' })
        end
        concat form.submit t("action.update_#{klass}", label: label), class: "btn-confirm"
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
        data: (with_stimulus ? stim_data.merge(label_data) : label_data),
        checked: item.send(prop) == o.value
      )
      content << form.label("visibility_#{o.value}".to_sym, tag.span(icon(o.icon)), for: id, title: title)
    end
    content = safe_join(content)
    tag.div(content, class: "visibility-radios")
  end

  def show_attribute_switch(form, attr)
    id = "ck_#{form.object_name.gsub(/[^a-z0-9]+/, '_').gsub(/_$/, '')}_#{attr}"
    tag.div(class: 'custom-control custom-checkbox') do
      form.check_box(attr, class: 'custom-control-input', id: id) +
        form.label(form.object.class.send(:human_attribute_name, attr), class: "custom-control-label", for: id)
    end
  end

  def remote_modal_for(uri, &block)
    content = capture(&block)
    link_to content, uri, data: { turbo_frame: :remote_modal }
  end

  def modal_dialog(title, &block)
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
