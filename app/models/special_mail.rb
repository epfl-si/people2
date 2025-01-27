# frozen_string_literal: true

class SpecialMail < SpecialOption
  def self.for_sciper_or_name(v)
    super&.first
  end

  def email
    data
  end
end
