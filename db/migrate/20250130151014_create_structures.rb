# frozen_string_literal: true

class CreateStructures < ActiveRecord::Migration[7.1]
  def change
    create_table :structures do |t|
      t.string :owners
      t.string :label
      t.string :description
      t.text :data

      t.timestamps
    end
  end
end
