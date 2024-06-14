# frozen_string_literal: true

class CreateAccreds < ActiveRecord::Migration[7.0]
  def change
    create_table :accreds do |t|
      t.references :profile
      t.integer :unit_id
      t.integer :position, null: false
      t.string  :sciper
      t.boolean :hidden
      t.boolean :hidden_addr
      t.string  :unit_fr
      t.string  :unit_en
      t.text    :role, null: false
      # legacy office_hide was a string listing location names for <300 profiles
      # I am not importing it for the moment
      # t.boolean :hidden_office

      t.timestamps
    end
    add_index :accreds, %i[profile_id position], unique: true
  end
end
