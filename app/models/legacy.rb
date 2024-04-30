# frozen_string_literal: true

module Legacy
  class LegacyBase < ApplicationRecord
    self.abstract_class = true
    self.inheritance_column = :_type_disabled
    def readonly?
      true
    end
  end

  class BaseCv < LegacyBase
    self.abstract_class = true
    if Rails.env.production?
      establish_connection :legacy_prod_cv
    else
      establish_connection :legacy_dev_cv
    end
  end
end
