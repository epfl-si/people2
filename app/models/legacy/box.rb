# frozen_string_literal: true

module Legacy
  class Box < Legacy::BaseCv
    self.table_name = 'boxes'
    self.primary_key = 'sciper'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :boxes

    scope :visible, -> { where(box_show: '1') }
    scope :with_content, -> { where("content IS NOT NULL and content <> ''") }
  end
end
