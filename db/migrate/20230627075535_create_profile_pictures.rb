class CreateProfilePictures < ActiveRecord::Migration[7.0]
  def change
    create_table :profile_pictures do |t|
      t.references :cv, null: false, foreign_key: true

      t.timestamps
    end
  end
end
