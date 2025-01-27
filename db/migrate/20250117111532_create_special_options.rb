# frozen_string_literal: true

class CreateSpecialOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :special_options do |t|
      t.string :sciper
      t.string :ns
      t.string :type, null: false
      t.text :data

      t.timestamps
    end
  end
end
