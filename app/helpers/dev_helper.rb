# frozen_string_literal: true

module DevHelper
  def visibility_access(audience = nil)
    return "" if audience.blank?

    a = case audience
        when 0
          t 'visibility.public_access'
        when 1
          t 'visibility.intranet_access'
        when 2
          t 'visibility.authenticated_access'
        when 3
          t 'visibility.editor_access'
        end
    "#{audience} (#{a})"
  end
end
