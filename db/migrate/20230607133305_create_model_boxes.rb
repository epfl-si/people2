class CreateModelBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :model_boxes do |t|
      t.references :section, null: false, foreign_key: true
      t.string :locale, default: "fr"
      t.string :title, null: false
      t.boolean :show_title, default: true
      t.integer :position
      t.timestamps
    end
  end
end
