# frozen_string_literal: true

class CreateNameChangeRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :name_change_requests do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :old_first
      t.string :old_last
      t.string :new_first
      t.string :new_last
      t.text :reason
      t.timestamps
    end
  end
end
