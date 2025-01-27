# frozen_string_literal: true

class SpecialRedirect < SpecialOption
  def self.for_sciper_or_name(v)
    super&.first
  end

  def url
    data
  end
end
