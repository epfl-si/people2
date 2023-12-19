# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[7.0]
  def change
    create_table :sections do |t|
      t.string :title_en
      t.string :title_fr
      t.string :label
      t.string :zone
      t.integer :position
      t.boolean :show_title
      t.boolean :create_allowed

      t.timestamps
    end
  end
end
