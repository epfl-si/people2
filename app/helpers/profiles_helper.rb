# frozen_string_literal: true

module ProfilesHelper
  def profile_text_field(form, attr, placeholder)
    lb = form.label form.object.class.send(:human_attribute_name, attr), class: "col-sm-3  col-form-label"
    fd = tag.div(class: "col-sm-9") do
      form.text_field attr, class: "form-control", placeholder: placeholder
    end
    lb + fd
  end

  def form_actions(form, item, without_cancel: false)
    klass = item.class.name.underscore
    tag.div(class: "form-actions") do
      if item.new_record?
        concat form.submit t("action.create_#{klass}"), class: "btn-confirm"
      else
        unless without_cancel
          concat link_to(t('action.cancel'),
                         send("#{klass}_path", item),
                         class: "btn-cancel", method: :get,
                         data: { turbo_stream: true, turbo_method: 'get' })
        end
        concat form.submit t("action.update_#{klass}"), class: "btn-confirm"
      end
    end
  end

  def visibility_switch0(form)
    id = form.object_name.gsub(/[^a-z0-9]+/, "_").gsub(/_$/, '')
    tag.div(class: 'col-sm-9 offset-sm-3') do
      tag.div(class: 'custom-control custom-checkbox') do
        concat form.check_box(:visible, class: 'custom-control-input', id: id)
        concat form.label(
          form.object.class.send(:human_attribute_name, "visible"),
          class: "custom-control-label",
          for: id
        )
      end
    end
  end

  def audience_selector0(form)
    id0 = form.object_name.gsub(/[^a-z0-9]+/, "_").gsub(/_$/, '')
    content = %w[public intranet authenticated draft].each_with_index.map do |v, i|
      id = "#{id0}_#{i}"
      label = "visibility.labels.#{v}"
      tag.div(class: "custom-control custom-radio audience-selector") do
        concat form.radio_button(:audience, i, id: id, class: "custom-control-input")
        concat form.label(t(label), class: "custom-control-label", for: id)
      end
    end
    tag.div(class: "col-sm-9") do
      safe_join(content)
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

  def audience_selector2(form)
    id0 = form.object_name.gsub(/[^a-z0-9]+/, "_").gsub(/_$/, '')
    content = %w[public intranet authenticated draft].each_with_index.map do |v, i|
      id = "#{id0}_#{i}"
      label = "visibility.labels.#{v}"
      tag.div(class: "custom-control custom-radio audience-selector") do
        concat form.radio_button(:audience, i, id: id, class: "custom-control-input")
        concat form.label(t(label), class: "custom-control-label", for: id)
      end
    end
    safe_join(content)
  end

  def audience_selector(form, with_stimulus: false)
    id0 = "#{form.object_name.underscore}_audience_#{form.object.id}"
    stim_data = { action: "input->visibility#onChange", "visibility-target": "radio" }
    content = []
    AudienceLimitable::AUDIENCE_OPTIONS.each_with_index do |o, i|
      id = "#{id0}_#{i}"
      label_data = { label: form.object.audience_label(i) }
      title = t "visibility.labels.#{o[:label]}"
      content << if with_stimulus
                   form.radio_button(:audience, i, id: id, data: stim_data.merge(label_data))
                 else
                   form.radio_button(:audience, i, id: id, data: label_data)
                 end
      content << form.label("audience_#{i}".to_sym, tag.span(icon(o[:icon])), for: id, title: title)
    end
    content = safe_join(content)
    tag.div(content, class: "visibility-radios")
  end

  def visibility_selector(form, with_stimulus: false)
    id0 = "#{form.object_name.underscore}_visibility_#{form.object.id}"
    stim_data = { action: "input->visibility#onChange", "visibility-target": "radio" }
    content = []
    AudienceLimitable::VISIBILITY_OPTIONS.each_with_index do |o, i|
      id = "#{id0}_#{i}"
      label_data = { label: form.object.visibility_label(i) }
      title = t "visibility.labels.#{o[:label]}"
      content << if with_stimulus
                   form.radio_button(:visibility, i, id: id, data: stim_data.merge(label_data))
                 else
                   form.radio_button(:visibility, i, id: id, data: label_data)
                 end
      content << form.label("visibility_#{i}".to_sym, tag.span(icon(o[:icon])), for: id, title: title)
    end
    content = safe_join(content)
    tag.div(content, class: "visibility-radios")
  end

  def show_attribute_switch(form, attr)
    id = "ck_#{form.object_name.gsub(/[^a-z0-9]+/, '_').gsub(/_$/, '')}_#{attr}"
    tag.div(class: 'custom-control custom-checkbox') do
      concat form.check_box(attr, class: 'custom-control-input', id: id)
      concat form.label(form.object.class.send(:human_attribute_name, attr), class: "custom-control-label", for: id)
    end
  end
end
