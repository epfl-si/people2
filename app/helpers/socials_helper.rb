# frozen_string_literal: true

module SocialsHelper
  def research_ids_options
    Social::RESEARCH_IDS.map { |key, value| [value['label'], key] }
  end

  def placeholder_for_tag(tag)
    if tag.present?
      Social::RESEARCH_IDS.dig(tag, 'url').gsub('XXX', '')
    else
      "Enter ID or Username"
    end
  end
end
