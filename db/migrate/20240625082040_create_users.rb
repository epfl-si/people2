# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      # t.string :password_digest, null: false
      t.string :name
      t.string :provider
      t.string :sciper
      t.timestamps
    end
    add_index :users, :sciper, unique: true
    # add_index :users, :email, unique: true
  end
end
