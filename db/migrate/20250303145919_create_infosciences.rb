# frozen_string_literal: true

class CreateInfosciences < ActiveRecord::Migration[8.0]
  def change
    create_table :infosciences do |t|
      t.references :profile, null: false, foreign_key: true
      t.string  :title_en
      t.string  :title_fr
      t.string  :title_it
      t.string  :title_de
      t.string  :url
      t.integer :position
      t.integer :visibility, default: 4 # 0=public, 4=hidden

      t.timestamps
    end
  end
end
