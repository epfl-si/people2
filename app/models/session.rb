# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :user
  def self.sweep(time = 2.hours)
    where(updated_at: ...time.ago).delete_all
  end
end
