# frozen_string_literal: true

# Epfl elements Collapse Group
# https://epfl-si.github.io/elements/#/molecules/collapse-group
# <button
#   class="collapse-title collapse-title-desktop [collapsed]"
#   type="button" data-toggle="collapse" data-target="#collapse-1"
#   aria-expanded="false" aria-controls="collapse-1"
# >
#   Title
# </button>
# <div
#   class="collapse collapse-item collapse-item-desktop [show]"
#   id="collapse-1"
# >
#   Content
# </div>
module ElementsHelper
  def ee_collapse(title, content_or_options_with_block = nil, options = {}, &block)
    indx = ApplicationController.unique_counter_value
    if block_given?
      content = capture(&block)
      options = content_or_options_with_block || {}
    else
      content = content_or_options_with_block
    end
    expanded = options.delete(:expanded)
    klass = %w[collapse-title collapse-title-desktop]
    klass << "collapsed" if expanded
    title_opts = {
      class: klass,
      data: {
        toggle: 'collapse',
        target: "#collapse-#{indx}"
      },
      aria: {
        expanded: expanded ? 'true' : 'false',
        controls: "collapse-#{indx}"
      }
    }
    content_opts = {
      class: %w[collapse collapse-item collapse-item-desktop],
      id: "collapse-#{indx}"
    }
    content_opts[:class] << 'show' if expanded
    content_tag(:button, title_opts) do
      content_tag(:p, title, class: 'title')
    end << content_tag(:div, content, content_opts)
  end
end
