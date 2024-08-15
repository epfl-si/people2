# frozen_string_literal: true

class CreateRedirects < ActiveRecord::Migration[7.1]
  def change
    create_table :redirects do |t|
      t.string :ns
      t.integer :sciper
      t.string :url

      t.timestamps
    end
  end
end
