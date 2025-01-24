# frozen_string_literal: true

class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.string :sciper
      t.integer :kind
      t.text :data

      t.timestamps
    end
  end
end
