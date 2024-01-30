# frozen_string_literal: true

class CreateProfilePictures < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_pictures do |t|
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
