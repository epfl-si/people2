# frozen_string_literal: true

class CreateAwards < ActiveRecord::Migration[7.0]
  def change
    create_table :awards do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :category, null: false
      t.references :origin, null: false
      t.string  :title_en
      t.string  :title_fr
      t.string  :issuer
      t.integer :year
      t.string  :url
      t.integer :position, null: false
      t.integer :audience, default: 0 # 0=public, 1=intranet, 2=authenticated user, 3=me (draft)
      t.boolean :visible, default: false

      t.timestamps
    end
    add_index :awards, %i[profile_id position], unique: true
    add_foreign_key :awards, :selectable_properties, column: :category_id
    add_foreign_key :awards, :selectable_properties, column: :origin_id
  end
end
