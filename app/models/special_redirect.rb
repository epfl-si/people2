# frozen_string_literal: true

class SpecialRedirect < SpecialOption
  # TODO: add validations

  def url
    data
  end

  def url=(v)
    self.data = v
  end
end
