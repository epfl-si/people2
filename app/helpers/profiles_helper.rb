# frozen_string_literal: true

module ProfilesHelper
  def profile_text_field(form, attr, placeholder)
    lb = form.label form.object.class.send(:human_attribute_name, attr), class: "col-sm-3  col-form-label"
    fd = tag.div(class: "col-sm-9") do
      form.text_field attr, class: "form-control", placeholder: placeholder
    end
    lb + fd
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

  AUDIENCE_OPTIONS = [
    { label: 'public', icon: 'globe' },
    { label: 'intranet', icon: 'home' },
    # {label: 'authenticated', icon: 'key'},
    # {label: 'owner', icon: 'user-check'},
    { label: 'authenticated', icon: 'user-check' },
    { label: 'owner', icon: 'edit-3' },
    { label: 'hidden', icon: 'eye-off' }
  ].freeze

  def audience_selector(form, with_stimulus: false, with_wrapper: true)
    form.object_name.underscore
    content = []
    AUDIENCE_OPTIONS.each_with_index do |o, i|
      title = t "visibility.labels.#{o[:label]}"
      content << if with_stimulus
                   form.radio_button(:audience, i, "data-action" => "input->visibility#onChange")
                 else
                   form.radio_button(:audience, i)
                 end
      content << form.label("audience_#{i}".to_sym, tag.span(icon(o[:icon])), title: title)
    end
    content = safe_join(content)
    with_wrapper ? tag.div(content, class: "visibility-radios") : content
  end

  def show_attribute_switch(form, attr)
    id = "ck_#{form.object_name.gsub(/[^a-z0-9]+/, '_').gsub(/_$/, '')}_#{attr}"
    tag.div(class: 'custom-control custom-checkbox') do
      concat form.check_box(attr, class: 'custom-control-input', id: id)
      concat form.label(form.object.class.send(:human_attribute_name, attr), class: "custom-control-label", for: id)
    end
  end
end
