# frozen_string_literal: true

# IndexBox is a placeholder for an index view of a model. It is used just for
# its title and visibility controls (inherited from Box)
# Currently avilable models models (variants) are the following:
#  - achievement
#  - award
#  - education
#  - experience

class IndexBox < Box
  ALLOWED_SUBKINDS = %w[Award Education Experience Publication Social].freeze

  translates_rich_text :content

  validates :subkind, presence: true, inclusion: { in: ALLOWED_SUBKINDS }

  def variant=(v)
    v.upcase_first
  end

  def variant
    subkind&.downcase
  end

  def plural_variant
    subkind&.downcase&.pluralize
  end

  def items
    profile.send(plural_variant.to_s)
  end

  def visible_items(audience_level = 0)
    profile.send(plural_variant.to_s).for_audience(audience_level)
  end

  def content?(_primary_locale = nil, _fallback_locale = nil)
    items.count.positive?
  end

  def content_for?(audience_level = 0, _primary_locale = nil, _fallback_locale = nil)
    visible_items(audience_level).count.positive?
  end
end
