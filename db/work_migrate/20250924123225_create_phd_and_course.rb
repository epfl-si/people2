# frozen_string_literal: true

class CreatePhdAndCourse < ActiveRecord::Migration[8.0]
  def change
    create_table :phds do |t|
      t.string  :sciper, null: false
      t.string  :director_sciper
      t.string  :codirector_sciper
      t.string  :name
      t.string  :cursus
      t.integer :thesis_number
      t.string  :thesis_title, limit: 500
      t.date    :date
      t.integer :year, null: false
      t.timestamps

      t.index [:codirector_sciper], unique: false
      t.index [:director_sciper], unique: false
    end

    create_table :courses do |t|
      t.string :acad, limit: 16, null: false
      t.string :slug, limit: 16, null: false
      t.string :slug_prefix, limit: 16, null: false
      t.string :lang, limit: 2
      t.string :level
      t.string :section
      t.string :semester
      t.string :title_en
      t.string :title_fr
      t.text   :description_en
      t.text   :description_fr
      t.timestamps

      t.index [:slug], unique: false
      t.index %i[acad slug], unique: true
    end
  end
end
