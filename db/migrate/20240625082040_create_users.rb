# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password
      t.string :provider
      t.string :sciper
      t.string :uid
      t.timestamps
    end
  end
end
