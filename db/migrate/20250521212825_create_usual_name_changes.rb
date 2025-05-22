# frozen_string_literal: true

class CreateUsualNameChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :usual_name_changes do |t|
      t.string :official_first, null: false
      t.string :official_last, null: false
      t.string :old_first
      t.string :old_last
      t.string :new_first
      t.string :new_last
      t.references :profile, null: false, foreign_key: true
      t.boolean :done, default: false

      t.timestamps
    end
  end
end
