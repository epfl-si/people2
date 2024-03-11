# frozen_string_literal: true

class CreateTeacherships < ActiveRecord::Migration[7.0]
  def change
    create_table :teacherships do |t|
      t.references :course, null: false, foreign_key: true
      t.references :profile, null: true, foreign_key: true
      t.string :sciper
      t.string :role
      t.string :kind

      t.timestamps
    end
  end
end
