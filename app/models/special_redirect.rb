# frozen_string_literal: true

class SpecialRedirect < SpecialOption
  # TODO: add validations

  def self.for_sciper_or_name(v)
    super&.first
  end

  def url
    data
  end

  def url=(v)
    self.data = v
  end
end
