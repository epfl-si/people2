# frozen_string_literal: true

class CreateSocial < ActiveRecord::Migration[7.0]
  def change
    create_table :socials do |t|
      t.references :profile
      t.string :sciper
      t.string :tag
      t.string :value
      t.integer :position, default: false
      t.integer :visibility, default: 3 # 0=public, 1=intranet, 2=authenticated, 3=owner, 4=hidden
      t.timestamps
    end
  end
end
