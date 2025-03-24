# frozen_string_literal: true

module SocialsHelper
  def placeholder_for_tag(tag)
    if tag.present?
      Social::RESEARCH_IDS.dig(tag, :url).gsub('XXX', '')
    else
      "Enter ID or Username"
    end
  end
end
