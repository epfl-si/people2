# frozen_string_literal: true

module Legacy
  class Box < Legacy::BaseCv
    self.table_name = 'boxes'

    include Ollamable
    ollamizes :content, :label

    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: :boxes

    scope :visible, -> { where(box_show: '1') }
    scope :with_content, -> { where("content IS NOT NULL and content <> ''") }
    # Boxes with sys not null are specialized and their content comes from other tables;
    scope :free_text, -> { where("sys IS NULL or sys = ''") }

    def visible?
      box_show == '1'
    end
  end
end
