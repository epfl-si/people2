# frozen_string_literal: true

class CreateSocial < ActiveRecord::Migration[7.0]
  def change
    create_table :socials do |t|
      t.references :profile
      t.string :sciper
      t.string :tag
      t.string :value
      t.integer :position, default: false
      t.integer :audience, default: 0 # 0=public, 1=intranet, 2=authenticated
      t.integer :visibility, default: 1 # 0=published, 1=draft, 2=hidden
      t.timestamps
    end
  end
end
