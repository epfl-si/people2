# frozen_string_literal: true

class CreateCv < ActiveRecord::Migration[7.0]
  def change
    create_table :cvs do |t|
      t.string  :sciper, index: { unique: true, name: 'unique_emails' }

      t.boolean :show_birthday
      t.boolean :show_function
      t.boolean :show_nationality
      t.boolean :show_phone
      t.boolean :show_photo
      t.boolean :show_title

      t.string :force_lang
      t.string :personal_web_url

      # Translatable attributes
      t.string :nationality_en
      t.string :nationality_fr
      t.string :title_en
      t.string :title_fr

      # this is now delegated to accred and requires approval
      # t.string :title_en
      # t.string :title_fr

      t.timestamps
    end
  end
end
