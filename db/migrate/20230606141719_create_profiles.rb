# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string  :sciper, index: { unique: true, name: 'unique_scipers' }

      # Visibilities
      t.integer :birthday_visibility, default: AudienceLimitable::HIDDEN
      t.integer :nationality_visibility, default: AudienceLimitable::HIDDEN
      t.integer :personal_phone_visibility, default: AudienceLimitable::HIDDEN
      t.integer :photo_visibility, default: AudienceLimitable::HIDDEN
      t.integer :personal_web_url_visibility, default: AudienceLimitable::HIDDEN
      t.integer :expertise_visibility, default: AudienceLimitable::VISIBLE
      # This concerns the default work phone coming from Person (accred)
      t.integer :phone_visibility, default: AudienceLimitable::VISIBLE

      t.string :personal_web_url, default: nil
      t.string :personal_phone, default: nil

      # Translatable attributes
      t.string :expertise_en, default: nil
      t.string :expertise_fr, default: nil
      t.string :expertise_it, default: nil
      t.string :expertise_de, default: nil

      t.string :nationality_en, default: nil
      t.string :nationality_fr, default: nil
      t.string :nationality_it, default: nil
      t.string :nationality_de, default: nil

      t.boolean :en_enabled, default: true
      t.boolean :fr_enabled, default: true
      t.boolean :it_enabled, default: false
      t.boolean :de_enabled, default: false

      t.timestamps
    end
  end
end
