# frozen_string_literal: true

class AddEmailNameToSciper < ActiveRecord::Migration[8.0]
  def change
    change_table :scipers, bulk: true do |t|
      t.string :email
      t.string :name
      t.index [:email], unique: true
    end
  end
end
