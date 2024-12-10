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

  def visible_items(_audience = 0)
    profile.send(plural_variant.to_s).where(visible: true)
  end
end
