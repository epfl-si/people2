# frozen_string_literal: true

# Standard box is a placeholder used just for its title and visibility controls
# The content is formatted as an index of the corresponding models with the
# possibility to add and edit one object in edit mode.
# Currently the possible variants are:
#  - achievement
#  - award
#  - education
#  - experience

class StandardBox < Box
  translates_rich_text :content

  validates :data, presence: true

  def variant
    data["variant"]
  end

  def variant=(v)
    data["variant"] = v
  end

  def plural_variant
    variant.pluralize
  end

  def visible_items(_audience = 0)
    profile.send(plural_variant.to_s).where(visible: true)
  end
end
