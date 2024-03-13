# frozen_string_literal: true

class CreatePictures < ActiveRecord::Migration[7.0]
  def change
    create_table :pictures do |t|
      t.references :profile, null: false, foreign_key: true
      t.boolean :camipro, default: false
      t.integer :failed_attempts, default: 0

      t.timestamps
    end
  end
end
