# frozen_string_literal: true

class CreateAccredPrefs < ActiveRecord::Migration[7.0]
  def change
    create_table :accred_prefs do |t|
      t.references :profile
      t.integer :unit_id
      t.integer :order
      t.string  :sciper
      t.boolean :hidden
      t.boolean :hidden_addr

      # legacy office_hide was a string listing location names for <300 profiles
      # I am not importing it for the moment
      # t.boolean :hidden_office

      t.timestamps
    end
  end
end
