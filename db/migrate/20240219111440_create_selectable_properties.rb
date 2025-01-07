# frozen_string_literal: true

class CreateSelectableProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :selectable_properties do |t|
      t.string   :name_en
      t.string   :name_fr
      t.string   :name_it
      t.string   :name_de
      t.string   :property, null: false
      t.timestamps
    end
  end
end
