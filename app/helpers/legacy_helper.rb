# frozen_string_literal: true

module LegacyHelper
  def position_with_class_delegate(affiliation, is_delegate, gender)
    [
      "<strong>#{affiliation.position.t_label(gender)}</strong>",
      is_delegate ? t('class_delegate') : nil,
      "<span class='font-weight-normal'>#{affiliation.t_unit_label}</span>"
    ].compact.join(', ').html_safe
  end

  def hierarchy_links(y)
    y.split(' ').map do |l|
      link_to(l, "https://search.epfl.ch/?filter=unit&acro=#{l}")
      # rubocop:disable Rails/OutputSafety
    end.join(' › ').html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
