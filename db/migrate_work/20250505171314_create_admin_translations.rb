# frozen_string_literal: true

class CreateAdminTranslations < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_translations do |t|
      t.string :file
      t.string :key
      t.string :en
      t.string :fr
      t.string :it
      t.string :de
      t.boolean :done

      t.timestamps
    end
    add_index :admin_translations, %i[key file], unique: true
  end
end
