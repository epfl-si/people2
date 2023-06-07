class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.references :cv, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.string :locale, default: "fr"
      t.string :title, null: false
      t.boolean :show_title, default: true
      t.boolean :frozen_title, default: false
      t.boolean :visible, default: false
      t.integer :position
      t.timestamps
    end
  end
end

