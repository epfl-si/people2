# Epfl elements Collapse Group
# https://epfl-si.github.io/elements/#/molecules/collapse-group
# <button class="collapse-title collapse-title-desktop [collapsed]" type="button" data-toggle="collapse" data-target="#collapse-1" aria-expanded="false" aria-controls="collapse-1">
#   Title
# </button>
# <div class="collapse collapse-item collapse-item-desktop [show]" id="collapse-1">
#   Content
# </div>
module ElementsHelper
  def ee_collapse(title, content_or_options_with_block = nil, options = {}, &block)
    @ee_collapse_indx ||= 0
    @ee_collapse_indx += 1
    indx = @ee_collapse_indx
    if block_given?
      content = capture(&block)
      options = content_or_options_with_block || {}
    else
      content = content_or_options_with_block
    end
    expanded = options.delete(:expanded)
    title_opts = {
      class: expanded ? %w[collapse-title collapse-title-desktop] : %w[collapse-title collapse-title-desktop collapsed],
      data: {
        toggle: "collapse",
        target: "#collapse-#{indx}"
      },
      aria: {
        expanded: expanded ? "true" : "false",
        controls: "collapse-#{indx}"
      }
    }
    content_opts = {
      class: %w[collapse collapse-item collapse-item-desktop],
      id: "collapse-#{indx}"
    }
    content_opts[:class] << "show" if expanded
    # res = content_tag(:section, class: "collapse-container") do
    #   content_tag(:header, hopts) do
    #     content_tag(:p, title, class: "title")
    #   end << content_tag(:div, content, class: %w(collapse collapse-item collapse-item-desktop), id: "collapse-#{indx}")
    # end
    res = content_tag(:button, title_opts) do
      content_tag(:p, title, class: "title")
    end << content_tag(:div, content, content_opts)
  end
end
