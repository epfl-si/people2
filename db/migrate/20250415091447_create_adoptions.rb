# frozen_string_literal: true

class CreateAdoptions < ActiveRecord::Migration[8.0]
  def change
    create_table :adoptions do |t|
      t.string :sciper, index: { unique: true, name: 'unique_scipers' }
      t.string :email, default: nil

      t.string :dn, default: nil
      t.string :fullname, default: nil
      t.boolean :with_legacy_profile, default: false
      t.boolean :accepted, default: false

      t.add_index :email, unique: true
      t.timestamps
    end
  end
end
