# frozen_string_literal: true

class CreateModelBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :model_boxes do |t|
      t.string     :kind, default: 'RichTextBox'
      t.string     :subkind, null: true
      t.integer :max_copies, default: 1
      t.references :section, null: false, foreign_key: true
      t.string :label, null: false
      t.string :title_en
      t.string :title_fr
      t.string :title_it
      t.string :title_de
      t.string :description_en
      t.string :description_fr
      t.string :description_it
      t.string :description_de
      t.boolean :standard, default: true
      t.boolean :show_title, default: true
      t.boolean :locked_title, default: true
      t.integer :position, null: false
      t.text :data, null: true
      t.timestamps

      t.index ["label"], unique: true
    end
  end
end
