class Cv < ApplicationRecord
  include Translatable
  translates :nationality
  has_translated_rich_text :curriculum, :expertise, :mission

  has_many :boxes,  :class_name => "box",   :foreign_key => "reference_id"

  def sciper
    self.id
  end

  def sciper=(v)
    self.id=(v.to_i)
  end
end
