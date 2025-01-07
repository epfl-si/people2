# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string  :sciper, index: { unique: true, name: 'unique_scipers' }

      # TODO: remove show_birthday as it is no longer available from API
      t.boolean :show_birthday
      t.boolean :show_function
      t.boolean :show_nationality
      t.boolean :show_phone
      t.boolean :show_photo
      t.boolean :show_weburl

      t.string :force_lang, default: nil
      t.string :default_lang, default: nil
      t.string :personal_web_url

      # Translatable attributes
      t.string :nationality_en
      t.string :nationality_fr
      t.string :nationality_it
      t.string :nationality_de

      # this is now delegated to accred and requires approval
      # t.string :title_en
      # t.string :title_fr
      # t.string :title_it
      # t.string :title_de

      t.timestamps
    end
  end
end
