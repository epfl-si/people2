# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string  :sciper, index: { unique: true, name: 'unique_scipers' }

      # TODO: remove show_birthday as it is no longer available from API
      t.boolean :show_birthday, default: false
      t.boolean :show_function, default: false
      t.integer :nationality_visibility
      t.integer :phone_visibility
      t.integer :photo_visibility
      t.integer :weburl_visibility

      t.string :personal_web_url

      t.string :phone, default: nil

      # Translatable attributes
      t.string :expertise_en
      t.string :expertise_fr
      t.string :expertise_it
      t.string :expertise_de

      t.string :nationality_en
      t.string :nationality_fr
      t.string :nationality_it
      t.string :nationality_de

      t.boolean :en_enabled, default: true
      t.boolean :fr_enabled, default: true
      t.boolean :it_enabled, default: false
      t.boolean :de_enabled, default: false

      t.timestamps
    end
  end
end
