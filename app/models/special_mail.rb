# frozen_string_literal: true

class SpecialMail < SpecialOption
  # TODO: add validations

  def email
    data
  end

  def email=(v)
    self.data = v
  end
end
