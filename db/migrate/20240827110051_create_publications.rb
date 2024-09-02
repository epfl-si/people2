# frozen_string_literal: true

class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.string :authors, null: false
      t.integer :year, null: false
      t.integer :position, null: false
      t.string :journal, null: false
      t.integer :audience
      t.boolean :visible

      t.timestamps
    end
  end
end
