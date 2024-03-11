# frozen_string_literal: true

class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.string :code
      t.string :title_en
      t.string :title_fr
      t.string :language_en
      t.string :language_fr

      t.timestamps
    end
  end
end
