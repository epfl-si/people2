# frozen_string_literal: true

class CreateArrExports < ActiveRecord::Migration[8.0]
  def change
    create_table :accreds_aar do |t|
      t.references :accred, null: false, foreign_key: false
      t.string :sciper, null: false
      t.integer :unit
      t.integer :ordre
      t.boolean :accred_show

      t.timestamps
    end

    create_table :awards_aar do |t|
      t.references :award, null: false, foreign_key: false
      t.string  :sciper, null: false
      t.integer :ordre
      t.string  :title
      t.string  :grantedby
      t.string  :url
      t.integer :year
      t.string  :category
      t.string  :origin

      t.timestamps
    end
  end
end
