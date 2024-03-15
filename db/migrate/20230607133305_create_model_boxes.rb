# frozen_string_literal: true

class CreateModelBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :model_boxes do |t|
      t.string     :kind, default: 'RichTextBox'
      t.references :section, null: false, foreign_key: true
      t.string :title_en, null: false
      t.string :title_fr, null: false
      t.boolean :show_title, default: true
      t.integer :position, null: false
      t.timestamps
    end
  end
end
