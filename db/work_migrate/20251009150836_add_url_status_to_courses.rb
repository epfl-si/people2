# frozen_string_literal: true

class AddUrlStatusToCourses < ActiveRecord::Migration[8.0]
  def change
    change_table :courses, bulk: true do |t|
      t.string :fallback_url_en, default: nil, limit: 2
      t.string :fallback_url_fr, default: nil, limit: 2
      t.boolean :urled, default: nil
    end
  end
end
