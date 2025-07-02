# frozen_string_literal: true

class Motd < ApplicationRecord
  include Translatable
  include WithSelectableProperties
  with_selectable_properties :category
  translates :title
  translates_rich_text :help

  scope :visible, -> { where('expiration > ?', Time.zone.today) }
  scope :for_frontend, -> { where(public: true).visible }

  def future_expiration
    t0 = Time.zone.today
    expiration.present? && expiration > t0 ? expiration : nil
  end

  def scope
    public? ? 'Public page too' : 'Backoffice only'
  end

  def visible?
    expiration.present? && expiration > Time.zone.today
  end
end
