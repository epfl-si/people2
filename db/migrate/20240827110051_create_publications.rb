# frozen_string_literal: true

class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.references :profile, null: false, foreign_key: true
      t.text :title, null: false
      t.string :url
      t.text :authors, null: false
      t.integer :year
      t.integer :position, null: false
      t.string :journal, null: false
      t.integer :visibility, default: 4 # 0=public, 4=hidden

      t.timestamps
    end
  end
end
