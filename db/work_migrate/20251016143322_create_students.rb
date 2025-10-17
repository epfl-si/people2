# frozen_string_literal: true

class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :sciper, limit: 6
      t.boolean :active, default: true
      t.boolean :delegate, default: false
      t.string :section
      t.string :semester, limit: 16
      t.string :level, limit: 32
      t.string :acad, limit: 10
      t.timestamps
      t.index [:sciper], unique: true
    end
  end
end
