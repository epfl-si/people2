# frozen_string_literal: true

class SpecialMail < SpecialOption
  # TODO: add validations

  def self.for_sciper_or_name(v)
    super&.first
  end

  def email
    data
  end

  def email=(v)
    self.data = v
  end
end
