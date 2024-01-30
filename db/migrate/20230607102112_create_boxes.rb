# frozen_string_literal: true

class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.string     :type, null: false
      t.references :profile, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.string     :title_en
      t.string     :title_fr
      t.boolean    :show_title, default: true
      t.boolean    :frozen, default: false
      t.boolean    :visible, default: false
      t.integer    :position
      t.timestamps
    end
  end
end
