# frozen_string_literal: true

module SocialsHelper
  def research_ids_options
    Social::RESEARCH_IDS.map { |key, value| [value['label'], key] }
  end

  def research_ids_dropdown(form)
    content_tag(:div, class: 'dropdown') do
      button_tag(type: 'button', class: 'btn btn-secondary dropdown-toggle', id: 'dropdownMenuButton',
                 data: { toggle: 'dropdown', turbo_stream: false }, aria: { haspopup: 'true', expanded: 'false' }) do
        form.object.tag.present? ? Social::RESEARCH_IDS.dig(form.object.tag, 'label') : "Choose an option"
      end +
        content_tag(:div, class: 'dropdown-menu', aria: { labelledby: 'dropdownMenuButton' }) do
          safe_join(Social::RESEARCH_IDS.map do |key, value|
            link_to value['label'], '#', class: "dropdown-item",
                                         data: { value: key, placeholder: value['label'] },
                                         onclick: "event.preventDefault(); " \
                             "document.getElementById('hidden_tag_field').value='#{key}'; " \
                             "document.getElementById('dropdownMenuButton').innerText='#{value['label']}'; " \
                             "document.getElementById('social_value').placeholder='#{value['label']}';"
          end)
        end
    end +
      form.hidden_field(:tag, id: "hidden_tag_field")
  end
end
