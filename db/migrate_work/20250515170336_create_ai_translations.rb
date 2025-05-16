# frozen_string_literal: true

class CreateAiTranslations < ActiveRecord::Migration[8.0]
  def change
    # TODO: do we need to disable_joins: true to belongs_to ?
    create_table :texts do |t|
      # t.references :record, null: false, polymorphic: true
      # t.string :name, null: false
      t.string :signature, index: { unique: true, name: "hopefully unique hash of the content" }
      t.text :content

      t.timestamps
    end
    create_table :ai_translations do |t|
      t.references :text, null: false, foreign_key: true
      t.string :ai_model, null: false
      t.float :confidence, null: true
      t.string :lang, null: true
      t.text :content_en, null: true
      t.text :content_fr, null: true
      t.text :content_it, null: true
      t.text :content_de, null: true

      t.timestamps
    end
  end
end
