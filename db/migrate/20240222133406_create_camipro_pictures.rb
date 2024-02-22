# frozen_string_literal: true

class CreateCamiproPictures < ActiveRecord::Migration[7.0]
  def change
    create_table :camipro_pictures do |t|
      t.references :profile, null: false, foreign_key: true
      t.integer :failed_attempts, default: 0

      t.timestamps
    end
  end
end
