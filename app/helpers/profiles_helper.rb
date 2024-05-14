# frozen_string_literal: true

module ProfilesHelper
  def profile_text_field(form, attr, placeholder)
    lb = form.label form.object.class.send(:human_attribute_name, attr), class: "col-sm-3  col-form-label"
    fd = tag.div(class: "col-sm-9") do
      form.text_field attr, class: "form-control", placeholder: placeholder
    end
    lb + fd
  end

  def visibility_switch(form)
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

  def audience_selector(form)
    id0 = form.object_name.gsub(/[^a-z0-9]+/, "_").gsub(/_$/, '')
    content = %w[public intranet authenticated me hidden].each_with_index.map do |v, i|
      id = "#{id0}_#{i}"
      label = "visibility.#{v}"
      tag.div(class: "custom-control custom-radio audience-selector") do
        concat form.radio_button(:audience, i, id: id, class: "custom-control-input")
        concat form.label(label, class: "custom-control-label", for: id)
      end
    end
    tag.div(class: "col-sm-9") do
      safe_join(content)
    end
  end

  def show_attribute_switch(form, attr)
    id = "ck_#{form.object_name.gsub(/[^a-z0-9]+/, '_').gsub(/_$/, '')}_#{attr}"
    tag.div(class: 'col-sm-9 offset-sm-3') do
      tag.div(class: 'custom-control custom-checkbox') do
        concat form.check_box(attr, class: 'custom-control-input', id: id)
        concat form.label(form.object.class.send(:human_attribute_name, attr), class: "custom-control-label", for: id)
      end
    end
  end
end
