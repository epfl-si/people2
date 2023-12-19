# frozen_string_literal: true

module LegacyHelper
  def position_with_class_delegate(affiliation)
    [
      "<strong>#{affiliation.t_position(I18n.locale)}</strong>",
      affiliation.class_delegate.nil? ? nil : t('class_delegate'),
      "<span class='font-weight-normal'>#{affiliation.unit.label(I18n.locale)}</span>"
    ].compact.join(', ').html_safe
  end

  # expect a type Legacy::PostalAddress as input
  def address(a)
    # rubocop:disable Rails/OutputSafety
    a.address_lines.map { |l| h l }.join('<br>').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def hierarchy_links(y)
    y.split(' ').map do |l|
      link_to(l, "https://search.epfl.ch/?filter=unit&acro=#{l}")
      # rubocop:disable Rails/OutputSafety
    end.join(' › ').html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
