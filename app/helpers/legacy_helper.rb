module LegacyHelper
  def position_with_class_delegate(affiliation)
    [
      "<strong>#{affiliation.t_position(I18n.locale)}</strong>",
      affiliation.class_delegate.nil? ? nil : t("class_delegate"),
      "<span class='font-weight-normal'>#{affiliation.unit.label(I18n.locale)}</span>"
    ].compact.join(", ").html_safe
  end

  # expect a type Legacy::PostalAddress as input
  def address(a)
    a.address_lines.join("<br>").html_safe
  end

  def hierarchy_links(y)
    y.split(" ").map do |l|
      link_to(l, "https://search.epfl.ch/?filter=unit&acro=#{l}")
    end.join(" › ").html_safe
  end
end
