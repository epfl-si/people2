# frozen_string_literal: true

class CreateSocial < ActiveRecord::Migration[7.0]
  def change
    create_table :socials do |t|
      t.references :profile
      t.string :sciper
      t.string :tag
      t.string :value
      t.integer :order, default: 1
      t.boolean :visible, default: true
      t.integer :audience, default: 0 # 0=public, 1=intranet, 2=authenticated user

      t.timestamps
    end
  end
end
