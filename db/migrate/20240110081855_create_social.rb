# frozen_string_literal: true

class CreateSocial < ActiveRecord::Migration[7.0]
  def change
    create_table :socials do |t|
      t.references :profile
      t.string :sciper
      t.string :tag
      t.string :value
      t.integer :order, default: 1
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
