# frozen_string_literal: true

class CreateMotds < ActiveRecord::Migration[8.0]
  def change
    create_table :motds do |t|
      t.references :category, null: false
      t.string :level, default: "info" # success info warning danger
      t.date :expiration
      t.boolean :public
      t.string :title_en
      t.string :title_fr
      t.string :title_it
      t.string :title_de

      t.timestamps
    end
  end
end
