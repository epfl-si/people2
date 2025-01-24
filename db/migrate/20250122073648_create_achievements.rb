# frozen_string_literal: true

class CreateAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :achievements do |t|
      t.integer    :audience, default: 0 # 0=public, 1=intranet, 2=authenticated
      t.integer    :visibility, default: 1 # 0=published, 1=draft, 2=hidden
      t.integer :position, null: false
      t.references :profile, null: false, foreign_key: true
      t.references :category, null: false
      t.integer :year, null: false
      t.text :description_en
      t.text :description_fr
      t.text :description_it
      t.text :description_de
      t.string :url

      t.timestamps
    end
  end
end
